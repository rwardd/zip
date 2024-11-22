const std = @import("std");
const CrossTarget = std.zig.CrossTarget;
const Target = std.Target;
const Feature = std.Target.Cpu.Feature;

pub fn build(b: *std.Build) void {
    const debug = b.option(bool, "debug", "Run qemu in debug mode") orelse false;
    const features = Target.riscv.Feature;
    var disabled_features = Feature.Set.empty;
    var enabled_features = Feature.Set.empty;

    disabled_features.addFeature(@intFromEnum(features.a));
    disabled_features.addFeature(@intFromEnum(features.c));
    disabled_features.addFeature(@intFromEnum(features.d));
    disabled_features.addFeature(@intFromEnum(features.e));
    disabled_features.addFeature(@intFromEnum(features.f));

    enabled_features.addFeature(@intFromEnum(features.m));

    const target = std.Target.Query{
        .cpu_arch = Target.Cpu.Arch.riscv32,
        .os_tag = Target.Os.Tag.freestanding,
        .abi = Target.Abi.none,
        .cpu_model = .{ .explicit = &std.Target.riscv.cpu.generic_rv32 },
        .cpu_features_sub = disabled_features,
    };

    const exe = b.addExecutable(.{
        .target = b.resolveTargetQuery(target),
        .name = "rvzg",
        .root_source_file = b.path("src/init.zig"),
    });

    exe.addAssemblyFile(b.path("arch/riscv/rv32/_start.S"));
    exe.setLinkerScriptPath(b.path("arch/riscv/rv32/link.ld"));

    b.installArtifact(exe);

    const qemu_args = .{
        "qemu-system-riscv32",
        "-machine",
        "virt",
        "-bios",
        "none",
        "-kernel",
        "zig-out/bin/rvzg",
        "-nographic",
    };

    const qemu = b.addSystemCommand(&qemu_args);

    if (debug) {
        qemu.addArg("-s");
        qemu.addArg("-S");
    }

    qemu.step.dependOn(b.default_step);
    const run_step = b.step("run", "Start qemu");

    run_step.dependOn(&qemu.step);
}
