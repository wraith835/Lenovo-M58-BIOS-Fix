# The no-flash workaround

Zero risk, fully reversible, takes a few minutes. Start here, even if you plan to do the permanent
fix eventually. It confirms the diagnosis on your own hardware before you touch anything
firmware-level.

## What this does

CMOS byte offset `0x52` (from the start of the standard CMOS bank) holds the PCI-hole size the BIOS
will use on the next boot, in units of 16 MiB. The firmware rewrites it to a small value (enough
for your graphics card, not enough to also fit all your RAM) at the end of every boot. Writing a
larger value into that byte just before each boot gives the BIOS enough room to finish setting up
memory. Nothing is flashed. Nothing about the BIOS code changes. If anything goes wrong, pulling
the CMOS battery restores the factory default and you're back to square one with nothing lost.

## Steps (Linux)

**1. Boot into a working configuration first** (less RAM, or the integrated graphics, whatever
currently boots) so you have a shell to run this from.

**2. Read the current value, just to see what you're working with:**
```sh
sudo modprobe nvram
sudo od -A d -t x1 -j 68 -N 1 /dev/nvram
```
(Linux's `/dev/nvram` interface addresses CMOS at offset = CMOS index − 14, so byte `0x52` is
offset 68.)

**3. Write a larger value — `0x40` (1024 MiB) is a safe, verified starting point:**
```sh
printf '\100' | sudo dd of=/dev/nvram bs=1 seek=68 count=1 conv=notrunc
sudo od -A d -t x1 -j 68 -N 1 /dev/nvram
```
Use the **octal** escape `\100`, not `\x40` — some shells' `printf` don't handle hex escapes
correctly and will write the literal wrong bytes instead. Confirm the read-back shows `40`.

**4. Power off completely, install the RAM and GPU you actually want to run, power on.** Don't
enter BIOS Setup first, just boot normally.

If this works, you'll boot straight through with everything installed and no error screen. That
confirms the diagnosis.

## Making it stick

The firmware rewrites that byte back down at the end of every boot, so it needs to be set again
before each power-on. A small systemd service does this automatically. It arms the byte at boot 
and at shutdown, so by the time the firmware checks it on the next power-on, it's already set correctly.

**Known limits:**
- A BIOS Setup visit, a non-OS boot (another USB stick, a recovery disc, a crash before your OS
  loads) leaves the byte un-rearmed for the *next* boot. The fix: boot once with less RAM or the
  integrated graphics (either reaches Setup fine or re-arms it), then boot normally again.
- Expect roughly 100–200 MiB less usable RAM than the theoretical maximum, from how the firmware
  rounds the top of memory. This is a firmware quirk independent of the workaround, not something
  it causes.
- If you want the problem gone and be independent of your OS, see the
  [permanent fix](PERMANENT_FIX.md) instead.
