# No-flash workaround: files

See [`../docs/WORKAROUND.md`](../docs/WORKAROUND.md) for the full explanation and manual steps
first. This folder just has the files for making it automatic.

## Files

- `arm-hole.sh` — the script itself. Checks the CMOS byte currently holds a value this family of
  BIOS is known to use (a safety check so it never writes over something unexpected), then arms it
  to `0x40` (1024 MiB hole).
- `m58p-arm-hole.service` — a systemd unit that runs the script at boot and at shutdown, so the
  byte is armed before the firmware checks it on the next power-on.

## Installing

```sh
sudo cp arm-hole.sh /usr/local/sbin/m58p-arm-hole
sudo chmod 755 /usr/local/sbin/m58p-arm-hole
sudo cp m58p-arm-hole.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now m58p-arm-hole.service
sudo journalctl -u m58p-arm-hole.service --no-pager | tail -5
```

Only install this after manually confirming the workaround boots your machine correctly at least
once (see [`../docs/WORKAROUND.md`](../docs/WORKAROUND.md)) — don't install it blind.

## Uninstalling

```sh
sudo systemctl disable --now m58p-arm-hole.service
sudo rm /etc/systemd/system/m58p-arm-hole.service /usr/local/sbin/m58p-arm-hole
sudo systemctl daemon-reload
```
