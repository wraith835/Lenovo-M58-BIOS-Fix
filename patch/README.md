# The patch

**Read [`../docs/VERIFY_YOUR_BOARD.md`](../docs/VERIFY_YOUR_BOARD.md) before anything in this
folder.** Everything here is gated on your firmware file matching one specific, verified hash. If
it doesn't match, stop — don't use these files on a different board or BIOS version.


1. Confirm your original firmware file's hash matches the verified original
   (`4df0a8f8b5220ab2735866818378103febac5c7134dd755b7a633ed0ba41a08c` — see
   [`../docs/VERIFY_YOUR_BOARD.md`](../docs/VERIFY_YOUR_BOARD.md)).


| File | SHA-256 |
|---|---|
| Verified original (`\$image5C.usf`, from Lenovo's `5CKT77A` DOS update package) | `4df0a8f8b5220ab2735866818378103febac5c7134dd755b7a633ed0ba41a08c` |
| Patched (`PATCH5C.usf`) | `7b12eb9c00cfe9df04689c0b3e18291ac62709ab58de109cf04ef06d9e36b16d` |

**See [`offsets.md`](offsets.md) if you would rather build your own BIOS image from a stock Lenovo image.**

## What the patch actually changes

Exactly three bytes, documented in full in [`offsets.md`](offsets.md). Nothing else in the 1.6 MB
file is touched — this was verified by comparing every byte of the patched file against the
original. The mechanism is explained in
[`../docs/TECHNICAL_DETAILS.md`](../docs/TECHNICAL_DETAILS.md).

## Flashing it

See [`../docs/PERMANENT_FIX.md`](../docs/PERMANENT_FIX.md) for the full walkthrough, don't just
flash this file without reading it.
