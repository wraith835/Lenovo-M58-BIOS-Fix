# What's actually wrong (plain-language explanation)

## The symptom

With a lot of RAM (12 GiB or more) and a discrete graphics card installed together, the machine
doesn't boot. It doesn't show an error. It doesn't beep. The fans spin, there's no video output,
and it never auto shuts down for a timeout. The machine will boot when either case is isolated, 
with either a full 16GB of RAM and no discrete GPU or a discrete GPU with less than 12GB installed.

## The background you need

Every PC needs to reserve a chunk of address space below the 4 GiB mark for things like your
graphics card to talk to. This is sometimes called the "PCI hole." Devices with a lot of their own
memory (modern GPUs, especially) need a bigger chunk of that reserved space than older or
integrated graphics do. Separately, your CPU has a small, fixed number of special registers (MTRRs
| Memory Type Range Registers) that tell it which parts of memory should be cached normally and
which shouldn't, seven of them on this generation of CPU, no more, ever. The system firmware's job
is to carve up your actual RAM into chunks that fit in those seven slots while also respecting the
PCI hole.

## Where it breaks

This BIOS decides how big the PCI hole needs to be by looking at a single byte it keeps in the
battery-backed CMOS memory — the same place that stores your clock and your boot order. After every
successful boot, it looks at whatever graphics card is actually installed and rewrites that byte to
match. With a modern GPU, that byte ends up set to a value that gives the card just enough room
and nothing more.

That "just enough for the card" hole turns out to be too small once you add up
how many separate chunks it takes to describe all your RAM around it. With more than about 10 GiB
installed, covering everything needs more chunks than there are MTRR slots available. The routine
that hands out those slots runs out, and because this is old BIOS code with no graceful
failure path, it just stops.

## Why it looks like a hardware limit but isn't

It is widely accepted in a lot of forums that this generation of ThinkCentre just can't handle this
much RAM with a modern GPU, and honestly the symptoms line up with that: no error, no beep, just a
dead screen, exactly what you'd expect from hitting an actual hardware wall.

But there's a detail that gives it away. If you clear CMOS (pull the battery), the machine boots
fine one time, then goes right back to failing on the very next boot with the exact same RAM and
GPU still installed. A real hardware limit doesn't come and go depending on what's sitting in
battery backed memory. Something is being calculated wrong and then stored, and clearing CMOS just
resets that stored number back to a safe default for one boot before the BIOS immediately
recalculates the same too-small value again.

## The two ways to fix it

1. **Make the BIOS use a bigger hole without ever touching its firmware.** The stored CMOS byte is
   just a number in battery-backed memory, nothing stops you from writing a bigger, safer value
   into it yourself before each boot. This is the [no-flash workaround](WORKAROUND.md): completely
   reversible, zero risk, works immediately. Note that this workaround was tested on a Linux OS and
   will only hold for one boot unless you make it a startup service. The downside to this is that it
   only works with that OS and effectively locks you out of accessing BIOS setup while you are booting
   with full RAM and GPU installed. The only workaround if you wish to access the BIOS setup while in
   this configuration is to remove RAM or the GPU.
2. **Fix the firmware so it never picks too small a value in the first place.** The routine that
   reads that CMOS byte can be told "never accept anything below this floor" with a tiny, three-byte
   edit. This is the [permanent fix](PERMANENT_FIX.md): requires flashing the BIOS chip once, after
   which the problem simply doesn't happen again, with nothing running in the background. This allows
   for a full successful boot and is independent of the OS you run. While patching in a custom BIOS
   image always has some level of risk, this is the correct solution to the problem.
