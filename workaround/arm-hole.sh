#!/bin/sh
# Arms CMOS byte 0x52 (nvram offset 68) = 0x40 so the BIOS uses a 1024 MiB PCI hole on
# the next boot, instead of the ~640 MiB hole it would otherwise re-learn for a
# discrete-GPU configuration. See ../docs/WORKAROUND.md for the full explanation.
#
# Only writes if the byte currently holds a value this BIOS family is known to produce
# or accept, so it can't stomp an unrelated or unexpected CMOS state.
set -e
modprobe nvram 2>/dev/null || true
cur=$(od -A n -t x1 -j 68 -N 1 /dev/nvram | tr -d ' \n')
case "$cur" in
  20|28|30|38|40|a0) ;;
  *)
    echo "m58p-arm-hole: unexpected CMOS byte '$cur' at offset 68, not writing" >&2
    exit 1
    ;;
esac
printf '\100' | dd of=/dev/nvram bs=1 seek=68 count=1 conv=notrunc 2>/dev/null || {
  echo "m58p-arm-hole: write failed" >&2
  exit 1
}
new=$(od -A n -t x1 -j 68 -N 1 /dev/nvram | tr -d ' \n')
[ "$new" = "40" ] || {
  echo "m58p-arm-hole: read-back '$new', expected 40" >&2
  exit 1
}
