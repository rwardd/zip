const std = @import("std");
const CrossTarget = std.zig.CrossTarget;
const Target = std.Target;
const Feature = std.Target.Cpu.Feature;

pub fn build(b: *std.Build) void {
    const debug = b.option(bool, "debug", "Run qemu in debug mode") orelse false;
    const arch_opt = b.option([]const u8, "architecture", "The target architecture") orelse "rv32";
    const arch = std.meta.stringToEnum(Arch, arch_opt).?;

    const board = b.option([]const u8, "board", "The target board") orelse "qemu";
    _ = board;

    const features = Target.riscv.Feature;
    const optimize = b.standardOptimizeOption(.{});
    var disabled_features = Feature.Set.empty;
    var enabled_features = Feature.Set.empty;

    disabled_features.addFeature(@intFromEnum(features.d));
    disabled_features.addFeature(@intFromEnum(features.e));
    disabled_features.addFeature(@intFromEnum(features.f));

    enabled_features.addFeature(@intFromEnum(features.a));
    enabled_features.addFeature(@intFromEnum(features.zicsr));
    enabled_features.addFeature(@intFromEnum(features.m));
    enabled_features.addFeature(@intFromEnum(features.c));

    const target = std.Target.Query{
        .cpu_arch = Target.Cpu.Arch.riscv32,
        .os_tag = Target.Os.Tag.freestanding,
        .abi = Target.Abi.none,
        .cpu_model = .{ .explicit = &std.Target.riscv.cpu.baseline_rv32 },
    };

    const exe = b.addExecutable(.{
        .target = b.resolveTargetQuery(target),
        .name = "rvzg",
        .root_source_file = b.path("src/init.zig"),
        .optimize = optimize,
    });

    const cpu_arch = b.addModule("arch", .{ .root_source_file = b.path(get_arch_path(arch)) });
    exe.root_module.addImport("arch", cpu_arch);
    initialise_architecture(arch, b, exe);
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

const architecture = struct {
    id: Arch,
    path: []const u8,
};

const Arch = enum(u32) { rv32, arm_cortex_m0 };
const arch_lookup = [_]architecture{architecture{ .id = Arch.rv32, .path = "arch/riscv/rv32/cpu.zig" }};

fn get_arch_path(arch: Arch) []const u8 {
    if (arch == Arch.rv32) {
        return arch_lookup[0].path;
    }

    return "Not found";
}

fn initialise_architecture(arch: Arch, b: *std.Build, exe: *std.Build.Step.Compile) void {
    switch (arch) {
        Arch.rv32 => {
            exe.addAssemblyFile(b.path("arch/riscv/rv32/_start.S"));
            exe.addAssemblyFile(b.path("arch/riscv/rv32/qemu_virt/irq.S"));
            exe.addAssemblyFile(b.path("arch/riscv/rv32/qemu_virt/vector.S"));
            exe.setLinkerScriptPath(b.path("arch/riscv/rv32/link.ld"));
        },
        else => {},
    }
}
