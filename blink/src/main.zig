// Pi with Zig
// By Alvaro Arenas
//
// Based on the work:
// Bare metal programming a Pi 3 in Zig.
// By Leandro Motta Barros
// Licensed under the MIT license. See LICENSE.txt.
//
// Welcome visitor from the future.
// I have left Leandro's explanations here for your convinience

// These are the addresses where some GPIO control registers are mapped to. They
// are marked as `volatile` to let the compiler know that accessing these
// addresses has side effects (and therefore these accesses will not be
// reordered or optimized away -- a property I'll explicitly make use of below).
const GPFSEL1 = @as(*volatile u32, @ptrFromInt(0x2020_0004));
const GPSET0 = @as(*volatile u32, @ptrFromInt(0x2020_001C));
const GPCLR0 = @as(*volatile u32, @ptrFromInt(0x2020_0028));

// This is the real entry point for our program, and the only part of it in
// assembly. That's just one instruction! It simply jumps (or branches, using
// the `b` instruction) to our main function, `simplestMain`, written in Zig
// below.
//
// One important thing here is that I place this code in the `.text.boot`
// section of the resulting object. The linker script, `simplest.ld`, makes sure
// this section is placed right at the beginning of the resulting binary. That's
// what I want, because the Raspberry Pi 3 will start running from the beginning
// of the binary.
//
// Maybe important: the linker will look (by default) for the `_start` symbol as
// the program entry point. As far as I understand, though, this isn't relevant
// for this program, because the Pi 3 will start running from the first byte of
// the image. I am really defining the entry point by using the `.text.boot`,
// and `_start` is effectivelly ignored. However, the linker will complain if it
// can find `_start`, so I define it here to make our tools happy. There's
// probably a more elegant way to do this.
comptime {
    asm (
        \\.section .text.boot
        \\.global _start
        \\_start:
        \\b simplestMain
    );
}

// This is the "Zig entry point" of our program. The "real entry point" is
// written above in assembly; but it doesn't to anything interesting, it just
// jumps to here.
export fn simplestMain() noreturn {
    // Configures the GPIO pin 16 as a digital output.
    GPFSEL1.* = 0x0004_0000;

    var ledON = true;

    var speed: u32 = 2000;

    while (true) {
        if (ledON) {
            // Set GPIO pin 16 to high.
            GPSET0.* = 0x0001_0000;
            sleep(1 * speed);
        } else {
            // Set GPIO pin 16 to low.
            GPCLR0.* = 0x0001_0000;
            sleep(1 * speed);
            if (speed > 2) {
                speed = speed / 2;
            }
        }

        // I am sure there are prettier ways to make the program sleep for a
        // while. Anyway, looping idly for a while is easy to understand and
        // works well-enough, especially considering I am targeting a specific
        // hardware.

        ledON = !ledON;
    }
}

fn sleep(times: u32) void {
    var i: u32 = 1_000;
    i = times * i;
    while (i > 0) {
        GPFSEL1.* = 0x0004_0000;
        i -= 1;
    }
}
