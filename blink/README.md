# Blink

A led blinker is the hardware's equivalent of the famous "hello world" programs.
You don't have any screen in bare metal development. The minimun you can do is to
set some of the general input output (GPIO) high and low.

Here I set the GPIO16 to blink.

This project is based in the amazing work by [Leandro Motta Barros]
(https://github.com/lmbarros/pi3-zig-simplest-bare-metal). Check it out for
throughful explanation on what every step is for.

## How to run

This project uses the raspberry pi zero but it can be easily converted to other pi. 
You can check the project from David (dwelch67) to know the differences in addresses.

So the minimum you can do is to just copy the ready made image into the sd card and wire
the GPIO16. This way you know you have the wiring correct.

## Compiling your own

You can use `make build` to create your own `kernel.img`. Notice that compiling your own image 
requires (as far as I understand) the following:

1. Compile your software which will be set with addresses starting at 0x00000. 
2. Use the linker to set the start addresses for your program at 0x8000. This is the address
where the raspberry bootloader will load your program. If those are not correct, it wont run.
The simple linker script does that. This step will generate an elf file.
3. Convert the elf file to machine code (bin) 

The build.zig does all of this steps. But I don't understand at this time why I need to use
`zig build dump-obj` instead of only `zig build`. At the time of writting I have used zig only
for a couple of days.
