# The permanent fix: flashing the patched BIOS

This walks through exactly what was done on the hardware this fix was verified on.
READ THIS ENTIRE DOCUMENT BEFORE STARTING THE PROCESS.

**Before you begin:**
- [ ] Confirmed your board and BIOS version against [`VERIFY_YOUR_BOARD.md`](VERIFY_YOUR_BOARD.md)
- [ ] Have YOUR DOS-bootable USB stick ([`FREEDOS_SETUP.md`](FREEDOS_SETUP.md))
- [ ] Have read [`RECOVERY.md`](RECOVERY.md) and know where the Clear CMOS/Recovery jumper is on
      your board, before you need to find it in a hurry
- [ ] Optionally: the [no-flash workaround](WORKAROUND.md) already confirmed on your hardware, not
      required, but a recommended easy check to see if this fix will actually work on your machine.

## 1. Prepare a recovery medium

Two options, do at least one before touching anything else:

- **Official recovery disc:** Lenovo publishes a stock BIOS update ISO for this board. Download it
  from Lenovo's own support site for your exact machine type (never a third-party mirror), verify
  its hash, and burn it to a CD/DVD — but don't boot it yet. These discs auto-launch their updater
  on boot; booting one "just to check" is not a safe dry run, it's the recovery action itself.
- **DIY USB recovery stick (recommended, easier to prepare):** make a second FreeDOS stick from
  [`FREEDOS_SETUP.md`](FREEDOS_SETUP.md), carrying only the flash tool and your **original,
  unmodified** firmware file. Leave `CONFIG.SYS` as it comes from Lenovo's package so it runs the
  updater automatically the moment it boots, same as the official disc. Because it auto-launches,
  double and triple check this stick only has your original file on it before you ever need it,
  there's no pause to catch a mistake once it's booting. This is a reasoned, not a
  hardware-proven, recovery path based off Lenovo's recommended steps for a BIOS recovery. Please
  refer to their support page if you have trouble during a recovery.

## 2. Back up your current BIOS before writing anything

Boot your flashing USB stick to a plain DOS prompt. **Don't run the update batch file yet.**

First, check the flash tool's own help to confirm its exact syntax for your version:
```
phlash16.exe /?
```

Then read the current flash contents out to a file:
```
phlash16.exe /RO=BACKUP.BIN /B:your_firmware_file.usf /A:00C00000
```

**BACKUP.BIN is an arbitrary file name you can assign to the backup. The second file name must match
the naming convention Lenovo uses for the BIOS .usf image ($image5C.usf).

**Copy `BACKUP.BIN` off this stick immediately**, onto a second USB drive or another machine. This
is your only copy of what's currently on the chip; treat it as irreplaceable until the whole
process is done and verified.

## 3. Checksum Errors You May See:

**You will very likely see "BIOS ROM file may be corrupt (checksum not zero)" on both the
original, factory firmware file and the patched one.** This is not a sign anything is wrong. This
BIOS generation doesn't use the older, simple "whole file sums to zero" checksum scheme that this
particular flag checks, so it flags every image of this type, including Lenovo's own untouched
file. This was verified directly during testing by running a checksum against a stock Lenovo image
which still fails. I did not dig any further into what new method they started using for a checksum
routine as I didn't see it as a worthwhile issue to chase down. 

## 4. Flash

Make sure the patched firmware file (`PATCH5C.usf` in `patch/` — see
[`patch/README.md`](../patch/README.md)) is on the stick **under a new filename, alongside your
untouched original — don't overwrite it.**

Run the flash with the exact command your vendor update package itself uses, changing only the
filename to point at the patched file instead of the original:

```
phlash16.exe /b:YOUR_PATCHED_FILE.usf /A:00C00000 /MODE=2 /S /X /MFG /P /EXIT /VCPU
```
Running it this way, straight from the command line with these flags, skips the interactive
Phoenix menu entirely. That matters because almost any way into that interactive menu runs the
same checksum check mentioned in step 3 first, and it fails. Running it this way never hit that
checksum failure once in testing. The flags themselves just run it silently, skip the XMS memory
manager check, and update CPU microcode during the flash.


**Do not power off or interrupt this under any circumstances once it starts.** Interrupting an
active write is the one thing that can actually damage the chip beyond what any recovery path can
fix. Everything else in this process is recoverable; a torn write mid-program is not.

## 5. What a successful flash looks like (and this is the other thing that tripped us up)

Depending on the flags you used, the tool may complete **silently** — one beep, no on-screen
message, straight back to a DOS prompt. **This is normal and does not mean it failed.** Some flag
combinations (particularly `/S` for silent operation and `/EXIT`) suppress the usual completion
screen. If you see this, it almost certainly means it finished, not that it crashed. If it does 
encounter an error the tool should abort the operation and not do a partial write.

If you get any error messages prior to a write, it is best to abort the operation and research 
the error code you are receiving. The patch made to this BIOS image is extremely minimal but when
handling any edits to a system's BIOS, extreme caution is always the best practice

## 6. Verify

Power off, then power on normally with the RAM and GPU you actually want to run. Don't arm the CMOS
byte manually, and don't have the workaround service (if you set one up) running, you want to see
the BIOS's own native behavior.

- **It should just boot.** No workaround, no manual steps, nothing.
- If you're on Linux, check the memory map to confirm the fix is actually active:
  ```sh
  sudo setpci -s 00:00.0 b0.w
  ```
  You're looking for a larger value than you saw before the patch (on the verified hardware this
  fix was built against, it went from `d800` to `c000` — the exact number depends on your RAM size
  and GPU, but it should be visibly different and the machine should boot where it didn't before).
- Repeat with a genuine cold power-off/power-on (not just a reboot), and once after visiting BIOS
  Setup and exiting, to confirm it's automatic every time with nothing special required.

If it boots cleanly and repeatably: you're done. The fix is permanent, lives in the firmware, and
needs nothing running in your OS.

If it doesn't come back up: see [`RECOVERY.md`](RECOVERY.md) immediately, don't experiment further
first.
