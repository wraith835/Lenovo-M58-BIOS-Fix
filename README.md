# Lenovo ThinkCentre M58 / M58p — 16 GiB RAM + modern GPU fix

**DISCLAIMER: EDITING YOUR BIOS IS ALWAYS A RISK, NO MATTER HOW WELL TESTED A PATCH MAY BE. I
TAKE NO RESPONSIBILITY IN ANY CHANGES YOU ELECT TO MAKE TO YOUR PERSONAL MACHINE WITH THE FILES
IN THIS REPO. PLEASE DO YOUR OWN RESEARCH ON THIS ISSUE AND HAVE A RECOVERY PLAN IN PLACE BEFORE
STARTING TO EDIT ANYTHING WITH YOUR BIOS IMAGE.**

**The short version:** if your M58/M58p silently hangs (black screen, no POST, fans spinning,
nothing) when you install 12 GiB or more of RAM together with a discrete graphics card, this
discovered BIOS bug is the reason why. This issue has been discussed in many forums for years
and has widely been accepted as a hardware limitation of what this motherboard can run, but 
the true issue lies in 3 key values in your BIOS code that silently stalls the boot sequence.

The root cause was found through actual disassembly of the BIOS, reproduced in an emulator against 
the real allocator code, and the fix was flashed and booted on real hardware: 16 GiB RAM + an 
NVIDIA GTX 1050 Ti, natively, with no workaround running.

## Is this for you?

This project is scoped and verified for **Lenovo ThinkCentre M58p, machine type 9965, BIOS version
`5CKT77AUS`**. The mechanism (described below) likely affects other M58/M58p machine types running
closely related Phoenix TrustedCore BIOS builds, since they share the same chipset generation
(Intel Q45/ICH10) and BIOS lineage but **the exact byte-level patch in this repo is only
verified safe for the exact BIOS version above.** If you do not have this exact model machine and
have not verified that your PC will accept that exact BIOS version, DO NOT PROCEED.

Of course, you are free to use this code for your own personal research and if you find proven models
or alternative methods for this patch to work, please share them and I will be sure to add them to this
repo.

## What's actually wrong (short version)

The BIOS decides how much address space to carve out below 4 GiB for PCI devices (the "PCI hole")
based on a single byte it stores in CMOS, and it re-learns that value after every boot to match
whatever graphics card is currently installed. With a modern GPU, it settles on a hole just large
enough for that card which turns out to be to small once 12GB or more of RAM is booted along side it.
You may have noticed that your machine will boot with full memory installed, or the gpu and a reduced
amount of RAM, but never both.

## Two fixes, pick one

| | [No-flash workaround](docs/WORKAROUND.md) | [Permanent BIOS patch](docs/PERMANENT_FIX.md) |
|---|---|---|
| Risk | None — one CMOS byte, reversible by a battery pull | Requires flashing the BIOS chip; recoverable if it fails |
| Effort | A few minutes, a small background service | Requires FreeDOS, a backup, and following the flashing guide exactly |
| Lasts through | Needs a tiny service running in your OS | Forever. The BIOS itself is fixed, no software needed afterward |
| Start here if... | you want to be running with 16 GiB + a GPU in the next five minutes | you're comfortable with a BIOS flash and want this solved for good |

Both are fully documented. You can do the workaround today and the permanent fix later they
don't conflict.

## Guides

1. [`docs/VERIFY_YOUR_BOARD.md`](docs/VERIFY_YOUR_BOARD.md) — **read this first, always**
2. [`docs/EXPLANATION.md`](docs/EXPLANATION.md) — what's actually broken, in plain language
3. [`docs/WORKAROUND.md`](docs/WORKAROUND.md) — the no-flash fix
4. [`docs/FREEDOS_SETUP.md`](docs/FREEDOS_SETUP.md) — making a bootable FreeDOS USB stick
5. [`docs/PERMANENT_FIX.md`](docs/PERMANENT_FIX.md) — the full flashing walkthrough
6. [`docs/RECOVERY.md`](docs/RECOVERY.md) — what to do if a flash goes wrong
7. [`docs/TECHNICAL_DETAILS.md`](docs/TECHNICAL_DETAILS.md) — more techincal explanation

## What's in this repo

- `patch/` — the pre-built patched BIOS image for the exact verified version (read [`patch/README.md`](patch/README.md)
  before using the pre-built file
- `workaround/` — the CMOS-arm script and the optional systemd service for the no-flash fix. (Linux)
- `docs/` — everything above.


## How this was found
Originally, this bug was discovered while building an M58 I received for free and I had the goal of making a capable,
budget friendly daily driver. This lead to a deep dive on the issue where the bug was eventually found.

The fix came out of a from-scratch reverse-engineering project: full BIOS disassembly, an x86 
emulator built to reproduce the exact allocator failure, and a lot of careful verification before 
anything was flashed to real hardware, working from the raw chip dump.

## AI Transparency
It would be dishonest for me to sit here and say I read through every hex table by hand to find this
solution. AI was leveraged in a great deal of compiling to save time (and sanity). While some of the 
emulations and decomposition was handled via AI, the hardware testing, verification, and deployment 
were all done by hand to ensure everything was correct

## Questions and Feedback
I am by no means an expert in this field and am always open to critique, edits, and further testing / deployment
of similar fixes on other machines. Please raise an issue through this repo or reach out directly and I will 
respond as soon as I can.

## License

MIT — see [`LICENSE`](LICENSE). Use it, fork it, improve it, and if you find this works (or
doesn't) on a different M58/M58p BIOS version, please open an issue with your exact version string
and SHA-256 so this can grow to cover more boards safely.

## Disclaimer

Flashing your BIOS always carries risk. This repo documents exactly what was done, what was
verified, and what to do if it goes wrong, but nobody can guarantee your specific board, chip, or
power situation behaves identically. The no-flash workaround carries none of that risk and is
recommended as the first thing to try. If you choose to flash, read every guide in full before you
start, and don't skip the backup step.
