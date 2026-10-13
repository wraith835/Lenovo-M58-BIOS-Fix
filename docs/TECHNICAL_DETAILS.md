# Technical details

This is the condensed version of the mechanism, for readers who want the actual facts behind the
plain-language explanation. Every claim here was established by disassembling the BIOS and
reproducing the behavior against the real, extracted firmware code in an emulator, then confirmed
on real hardware.

##AI USAGE##
I want to be transparent that most of the hex table de-compilation was handed off to an AI agent to
save time in identifying areas of focus for editing the PCI hole size. Implementation and hardware
testing for the final patch was done by hand.

## Hardware this was verified against

Lenovo ThinkCentre M58p, machine type 9965, Intel Q45/ICH10DO chipset, Phoenix TrustedCore BIOS
`5CKT77AUS`, Core 2 Quad Q9400 (`IA32_MTRRCAP` = `0xD07`: 7 variable MTRRs, SMRR supported;
`IA32_FEATURE_CONTROL` = `0xF`).

## The stored value

CMOS offset `0x52` (Setup/NVT token `0x062D`, 8 bits, outside the BIOS's own checksummed CMOS
range) holds the PCI hole size in units of 16 MiB. Factory default is `0xA0` (160 × 16 MiB = 2,560
MiB). Every image saved from a machine running a discrete GPU shows `0x28` (40 × 16 MiB = 640 MiB)
instead, the firmware's own learned value for that configuration. This is why setup is able to be 
reached because the firmware has not yet learned the reduced sizing.

## The reader

Early in POST, before the memory controller is configured, a routine reads this byte and validates
it: it must be a multiple of 8 and at least 8, or it's replaced with the factory default and
written back. The validated value, shifted left 4 (× 16), becomes the hole size handed to Intel's
memory reference code (MRC), which uses it to compute `TOLUD` (top of low usable DRAM) and the
related remap registers.

## The learning routine

After PCI resource assignment completes later in the same boot, a separate routine re-derives the
hole size from the lowest assigned PCI resource base address (with a discrete GPU, this is
typically the card's prefetchable BAR window) and writes the result back to the same CMOS byte,
rounded up to a multiple of 8 for the *next* boot. It only forces an immediate restart if the
newly computed hole needs to be *larger* than what's currently stored; if the stored value is
already big enough, it just updates the byte and continues normally.

## Why a small hole breaks at 12+ GiB

The BIOS's final memory-setup stage allocates one variable MTRR (a write-back cacheable range) per
contiguous block of RAM it needs to describe, after carving out the PCI hole. With a 640 MiB hole
and more than roughly 10 GiB of RAM installed, covering all of RAM without overlapping the hole
requires enough blocks that there are no MTRR slots left. On a CPU with 7 variable MTRRs, the allocator 
runs out of registers it can grant and halts the machine with no error path. A larger hole needs fewer 
blocks to describe the same amount of RAM (because the *available* low RAM below the hole shrinks, 
pushing more of your RAM into fewer, larger high-memory blocks), and the same allocator completes normally.

This also explains the "clearing CMOS fixes it for one boot" behavior some owners report: a CMOS
clear resets the stored byte to the large factory default, which boots fine and satisfies the
allocator, then the learning routine immediately writes the small, GPU-sized value back for
next time, so the very next boot fails again.

## The fix

A three-byte edit to the reader routine: instead of accepting any stored value ≥ 8 (× 16 MiB = 128
MiB) and a multiple of 8, it now requires a value ≥ 64 (× 16 MiB = 1,024 MiB). Anything smaller
stored in CMOS, including whatever the learning routine writes after a boot with a small-hole-
requiring GPU gets silently floored up to the new 1,024 MiB minimum before being handed to the
memory controller, every single boot. Any genuinely larger value the learning routine ever needs to
store (a future GPU needing more room, for instance) is still honored unchanged, and the existing
"restart if the hole must grow" logic in the learning routine is untouched, so there's no
possibility of a boot loop.

The net effect: the firmware always uses at least a 1,024 MiB hole from now on, which keeps the
final memory layout at 5 write-back MTRR ranges instead of 7 even with the maximum RAM and a
discrete GPU installed — comfortably under the 7-register limit. In some use cases this will 
cause you to see less available memory than what is currently installed, but it is a minmal
amount and the added RAM you are now able to run still nets you positive.

## Why this wasn't caught by Lenovo originally

The CPUs this chipset generation shipped with mostly topped out well under the RAM capacity where
this becomes visible, and the firmware's own learned value is only "too small" in combination with
(a) a GPU whose BAR layout pushes the learned hole down near the minimum the reader will accept,
and (b) enough installed RAM to need the extra MTRR slots. Neither condition alone triggers it.

## Verification performed before any hardware flash

- The three byte offsets and their semantics were established by disassembling the raw, uncompressed
  module containing the reader routine, and independently cross-checked by a second reviewer
  working from the same chip dump.
- A Unicorn-based x86 emulator reproduced the real MTRR allocator routine (not a reimplementation.
  The actual extracted machine code) against the exact CPU register values, confirming the
  halt at 12/16 GiB with the small hole and successful allocation with the patched minimum, across
  more than 20 explicit test cases.
- The patched reader routine was executed natively (in-emulator) against all 256 possible stored
  byte values to confirm correct behavior at every input, with no edge cases bypassed.
- Only after all of the above was the patch actually
  flashed to real hardware where it was accepted by the vendor's own flashing tool and the
  machine booted successfully, repeatably, with the predicted memory map.
