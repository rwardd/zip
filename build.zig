const std = @import("std");
const CrossTarget = std.zig.CrossTarget;
const Target = std.Target;
const Feature = std.Target.Cpu.Feature;

pub fn build(b: *std.Build) void {
    const debug = b.option(bool, "debug", "Run qemu in debug mode") orelse false;

    const arch_opt = b.option([]const u8, "architecture", "The target architecture") orelse "arm_cortex_m0";
    const arch = std.meta.stringToEnum(Arch, arch_opt).?;
    const platform_opt = b.option([]const u8, "platform", "The target platform") orelse "qemu_virt";
    const platform = std.meta.stringToEnum(Platform, platform_opt).?;

    const optimize = b.standardOptimizeOption(.{});
    const target = select_target(arch);

    const exe = b.addExecutable(.{
        .target = b.resolveTargetQuery(target),
        .name = "zip",
        .root_source_file = b.path("src/init.zig"),
        .optimize = optimize,
    });

    const cpu_arch = b.addModule("arch", .{ .root_source_file = b.path(get_arch_path(arch)) });
    exe.root_module.addImport("arch", cpu_arch);
    initialise_architecture(arch, b, exe);
    b.installArtifact(exe);

    const qemu_args = qemu_config(arch, platform);
    const qemu = b.addSystemCommand(qemu_args);

    if (debug) {
        qemu.addArg("-s");
        qemu.addArg("-S");
    }

    qemu.step.dependOn(b.default_step);
    const run_step = b.step("run", "Start qemu");
    run_step.dependOn(&qemu.step);
}

const Arch = enum(u32) { rv32, arm_cortex_m0, unknown };
const Platform = enum(u32) { qemu_virt };

const architecture = struct {
    id: Arch,
    path: []const u8,
};

const arch_lookup = [_]architecture{
    architecture{ .id = Arch.rv32, .path = "arch/riscv/rv32/cpu.zig" },
    architecture{ .id = Arch.arm_cortex_m0, .path = "arch/arm/cpu.zig" },
};

fn get_arch_path(arch: Arch) []const u8 {
    return arch_lookup[@intFromEnum(arch)].path;
}

fn select_target(arch: Arch) std.Target.Query {
    switch (arch) {
        Arch.rv32 => {
            return std.Target.Query{
                .cpu_arch = Target.Cpu.Arch.riscv32,
                .os_tag = Target.Os.Tag.freestanding,
                .abi = Target.Abi.none,
                .cpu_model = .{ .explicit = &std.Target.riscv.cpu.baseline_rv32 },
            };
        },
        Arch.arm_cortex_m0 => {
            return std.Target.Query{
                .cpu_arch = Target.Cpu.Arch.arm,
                .os_tag = Target.Os.Tag.freestanding,
                .abi = Target.Abi.none,
                .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m0 },
            };
        },
        else => {
            return std.Target.Query{};
        },
    }
}

fn initialise_architecture(arch: Arch, b: *std.Build, exe: *std.Build.Step.Compile) void {
    switch (arch) {
        Arch.rv32 => {
            exe.addAssemblyFile(b.path("arch/riscv/rv32/_start.S"));
            exe.addAssemblyFile(b.path("arch/riscv/rv32/qemu_virt/irq.S"));
            exe.addAssemblyFile(b.path("arch/riscv/rv32/qemu_virt/vector.S"));
            exe.setLinkerScriptPath(b.path("arch/riscv/rv32/link.ld"));
        },
        Arch.arm_cortex_m0 => {
            exe.addAssemblyFile(b.path("arch/arm/_start.S"));
            exe.addAssemblyFile(b.path("arch/arm/irq.s"));
            exe.setLinkerScriptPath(b.path("arch/arm/link.ld"));
        },
        else => {},
    }
}

fn qemu_config(arch: Arch, board: Platform) []const []const u8 {
    switch (arch) {
        Arch.rv32 => {
            switch (board) {
                Platform.qemu_virt => {
                    return &[_][]const u8{
                        "qemu-system-riscv32",
                        "-machine",
                        "virt",
                        "-bios",
                        "none",
                        "-kernel",
                        "zig-out/bin/zip",
                        "-nographic",
                    };
                },
            }
        },
        Arch.arm_cortex_m0 => {
            switch (board) {
                Platform.qemu_virt => {
                    return &[_][]const u8{
                        "qemu-system-arm",
                        "-machine",
                        "lm3s6965evb",
                        "-kernel",
                        "zig-out/bin/zip",
                        "-nographic",
                    };
                },
            }
        },
        else => {
            return &[_][]const u8{};
        },
    }
}
