//
// Pi with Zig
// By Alvaro Arenas
// Licensed under the MIT license. See LICENSE.txt.
//

const std = @import("std");

pub fn build(b: *std.build.Builder) !void {

    // Maybe I should use some other mode that doesn't do any optimization?
    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = std.builtin.Mode.ReleaseFast });

    // Here I set the target for the Raspberry Pi Zero (v1).
    const target = std.zig.CrossTarget{ .abi = .eabihf, .cpu_arch = .arm, .os_tag = .freestanding, .cpu_model = .{ .explicit = &std.Target.arm.cpu.arm1176jz_s } };

    // Set the executable target. Notice that this is an intermediary step.
    // The final is kernel.img set below.
    const exe = b.addExecutable(.{
        .name = "kernel.elf",
        .root_source_file = .{ .path = "src/main.zig" },
        .optimize = optimize,
        .target = target,
    });

    // Use the linker step to put the correct addresses to the final binary.
    exe.setLinkerScriptPath(std.build.FileSource{
        .path = "memmap.ld",
    });

    // Build the kernel.elf
    b.installArtifact(exe);

    // Add a step to convert  elf 32-bit executable into machine code.
    const dumpBinCommand = b.addSystemCommand(&[_][]const u8{ "arm-none-eabi-objcopy", "zig-out/bin/kernel.elf", "-O", "binary", "kernel.img" });
    dumpBinCommand.step.dependOn(b.getInstallStep());
    const dumpBinStep = b.step("dump-bin", "Disassemble the raw binary image");
    dumpBinStep.dependOn(&dumpBinCommand.step);
}
