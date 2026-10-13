# If the flash goes wrong

Read this *before* you flash, not after. You want to already know these steps if you ever need
them.

## Signs something's wrong

The machine doesn't reach POST at all after the flash. Note that you will also not reach POST
if the BIOS image didnt take and you are running the RAM and GPU together still. An easy check
to tell whats causing it is to either remove the gpu and boot off integrated graphics or remove
ram below 12GB. If the hang persists that is a clear sign that your flash did not save correctly.

## Recovery procedure (Lenovo's official route)

Lenovo documents an internal recovery jumper on this board for exactly this situation:

1. **Power off and unplug the machine.**
2. **Open the case.** Consult your machine's Hardware Maintenance Manual (available from Lenovo's
   support site for your exact machine type) for the exact jumper location, it's labeled "Clear
   CMOS/Recovery" on the board.
3. **Move the jumper** from its normal position (pins 1–2) to the recovery position (pins 2–3).
4. **Boot the official recovery disc** you prepared in step 1 of the flashing guide. With the
   jumper in the recovery position, the board uses a minimal recovery firmware path instead of the
   (possibly damaged) main BIOS, and the disc's updater should run automatically.
5. **Let it reflash your original, untouched firmware file** — not the patched one — to restore
   the known-good state.
6. **Power off, move the jumper back** to its normal position (1–2).
7. **Power on normally.**

If you prepared a DIY USB recovery stick instead of (or in addition to) the official disc: boot it
the same way with the jumper in the recovery position, and once the USB is selected the updater should
run automatically. This happens because CONFIG.SYS was left untouched on the recovery usb.

## If it still doesn't come back up after that

Stop. Don't keep experimenting. At this point you're dealing with something outside what this
guide covers, and further blind attempts risk making it worse rather than better. If you have
access to a SPI flash programmer and a way to read/write the chip directly (in-circuit or removed),
that's the next fallback, but that's genuinely a different, more involved repair than anything in
this repo walks through.

## Why this works

This board's recovery path is implemented in a small, separate section of the firmware (the "boot
block") that's distinct from the larger main BIOS image this patch modifies. The recovery jumper
tells the board to use that separate, minimal path instead of trying to run the (possibly broken)
main firmware — which is exactly why it can recover even if the main BIOS is in a bad state. It has
been observed in testing that the boot block remains untouched by the flash tool unless you explicitly
tell it to update it so this is a known good route back into the BIOS.
