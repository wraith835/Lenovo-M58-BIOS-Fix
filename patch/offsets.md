# Patch offsets

Applies to: the firmware image file (`\$image5C.usf`) inside Lenovo's `5CKT77A` DOS BIOS update
package for the M58p, machine type 9965, SHA-256
`4df0a8f8b5220ab2735866818378103febac5c7134dd755b7a633ed0ba41a08c`.

**Do not apply these offsets to any other file.** They are specific byte positions in this exact
firmware image. If your file doesn't match the hash above, these numbers mean nothing on your
file — see [`../docs/VERIFY_YOUR_BOARD.md`](../docs/VERIFY_YOUR_BOARD.md).

| File offset | Original byte | Patched byte |
|---|---|---|
| `0x161C91` | `0x08` | `0x40` |
| `0x161C95` | `0xA0` | `0x40` |
| `0x161C9E` | `0xA0` | `0x40` |

No other byte in the file changes. The file length is unchanged (1,609,566 bytes).

## What these three bytes are

They sit inside the routine (raw, uncompressed, at file offset `0x160020` onward) that reads the
stored PCI-hole value from CMOS at the start of POST. In the original code, the comparison
`cmp ax, 0x08` (encoded with the immediate byte at `0x161C91`) and the two substitution values
`0xA0` (at `0x161C95` and `0x161C9E`) together mean: "accept any stored value that's a multiple of
8 and at least 8 (× 16 MiB = 128 MiB); otherwise substitute 160 (× 16 MiB = 2,560 MiB)."

Changing the comparison immediate to `0x40` and both substitution values to `0x40` changes that to:
"accept any stored value that's a multiple of 8 and at least 64 (× 16 MiB = 1,024 MiB); otherwise
substitute 64 (× 16 MiB = 1,024 MiB)." Any value the firmware's own learning routine ever stores
below that floor gets raised to the floor before being used; any value already at or above the
floor is left exactly as-is, including the original factory default of `0xA0` (2,560 MiB), so a
genuinely larger future requirement is still honored unchanged.

Full explanation of what this fixes: [`../docs/TECHNICAL_DETAILS.md`](../docs/TECHNICAL_DETAILS.md).

## Applying by hand

If you'd rather not trust the BIOS image provided in this repo, open your *own, verified* firmware file 
with a hex editor of your choosing, go to each offset above, and change the bytes
