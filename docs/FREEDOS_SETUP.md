# Making a bootable FreeDOS USB stick

Lenovo's BIOS update tools for this generation of hardware require a FreeDOS or MS-DOS environment
to run smoothly. There are ISO images and a windows tool they provide, but it is highly recommended
to do this update through FreeDOS as it costs no more than a single thumb drive to set it up.

## What you need

- A small USB flash drive
- [Rufus](https://rufus.ie) if you're preparing the stick from Windows, **or** a FreeDOS boot image
  from [freedos.org/download](https://www.freedos.org/download/) if you're doing it from Linux or
  don't want to use Rufus.
- Your Lenovo BIOS update package for your exact machine (see
  [`VERIFY_YOUR_BOARD.md`](VERIFY_YOUR_BOARD.md) — only use a package matching your verified
  version).

## Using Rufus (Windows)

1. Insert the USB stick.
2. Open Rufus, select the drive.
3. **Boot selection:** choose "FreeDOS".
4. **Partition scheme:** MBR.
5. **File system:** FAT32 (try FAT16 instead if the board has trouble booting it — older BIOSes
   can occasionally be picky).
6. Click Start. This formats the drive and makes it bootable to a plain FreeDOS prompt.
7. Once it's done, copy your Lenovo update package's files onto the root of the drive —
   `PHLASH16.EXE`, the firmware image file, and any supporting files from the package.

## Using a FreeDOS boot image (Linux, or without Rufus)

1. Download the FreeDOS "USB boot" image from [freedos.org/download](https://www.freedos.org/download/).
2. Write it to the USB stick:
   ```sh
   sudo dd if=FD13-FloppyEdition.img of=/dev/sdX bs=4M status=progress
   ```
   (Replace `/dev/sdX` with your actual USB device — double-check this with `lsblk` first; getting
   it wrong writes over the wrong disk.)
3. Mount the resulting FAT partition and copy your update package's files onto it.

## Important: for your main flashing stick, don't let it auto-launch anything

Some Lenovo update packages ship a `CONFIG.SYS` that sets the flash tool itself as the DOS shell
(a line like `shell=flash2.exe /r`) — meaning the stick boots straight into the updater with no
plain prompt at all. For the stick you'll actually run the flash from, open `CONFIG.SYS` in a text
editor (from Linux, Windows, wherever) and remove or comment out any `shell=` line that points at a
flash tool, so the stick drops to a normal DOS prompt instead. This lets you look around the
directory and run each tool manually.

Your recovery stick is different — leave its `CONFIG.SYS` alone so it auto-launches the same way
the official disc does. See [`PERMANENT_FIX.md`](PERMANENT_FIX.md) and
[`RECOVERY.md`](RECOVERY.md) for why.

## Testing it

This is for your flashing stick, don't boot the recovery stick just to test it, it's supposed to
auto-launch and that's not something you want to trigger before you actually need it.

Boot the machine from the flashing stick (use your BIOS's one-time boot-device menu — usually a key
like F12 at power-on; check your board's manual if unsure) and confirm you land at a plain DOS
prompt (`C:\>` or similar). If it auto-launches something, go back and check `CONFIG.SYS`.
NOTE: Keep a close eye on the screen, it may ask you to "press any key" to continue into DOS.

Once you have a working, plain-prompt DOS stick, move on to [`PERMANENT_FIX.md`](PERMANENT_FIX.md).
