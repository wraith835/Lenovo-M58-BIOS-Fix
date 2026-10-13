# Verify your board before you do anything else

**This is not optional** The permanent patch in this repo edits three
specific bytes at three specific locations inside one specific BIOS file. Those offsets were found
by disassembling that exact file. If your board is running a different BIOS version, even a
different revision of the same model, the bytes at those offsets could be anything, and writing
`0x40` over them could do something else entirely.

## What's verified

- **Machine:** Lenovo ThinkCentre M58p, machine type 9965 (the fix was developed and flashed on a
  9965-A2U).
- **BIOS version:** `5CKT77AUS`
- **Exact original DOS update-package firmware file hash (SHA-256):**
  `4df0a8f8b5220ab2735866818378103febac5c7134dd755b7a633ed0ba41a08c`

If your version string and hash match these exactly, you're on verified hardware and can proceed.

## Why "M58/M58p" and not a longer list

The underlying bug (described in [`EXPLANATION.md`](EXPLANATION.md)) is not specific to this one
BIOS build. It's a general pattern in how this chipset-era Phoenix TrustedCore firmware manages
the PCI address hole, and it plausibly affects other M58/M58p machine types and other BIOS
revisions in the same family. But "plausibly affects" is not the same as "verified safe to patch."
I have only run this on this exact machine and BIOS so I cannot confirm its accuracy on other machines.

**If you have a different Lenovo and want to contribute to this repo with other known working models,
please feel free to reach out**

## How to check your version

**From BIOS Setup:** power on, press F1 to enter Setup, and look for the BIOS version string on
the main/info page. You're looking for `5CKT77AUS` specifically — not just "5CKT" or "M58p", the
full string including the revision letters. While you do not need to be on the most updated version
of the BIOS to run this, the flash is based off of that updated version so a safe pre check before
attempting this patch is to make sure your machine accepts a stock update prior.

**Note that this only applies to doing a BIOS patch, if you are going to do the workaround method,
it is a much safer test as the edit will only stick for one boot where it will then revert back to
the learned value.**
