const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const physac_c_dep = b.dependency("physac-c", .{
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addStaticLibrary(.{
        .name = "physac",
        .root_source_file = b.path("lib/physac.zig"),
        .target = target,
        .optimize = optimize,
    });

    const gen_step = b.addWriteFiles();
    const physac_c_path = gen_step.add("physac.c",
        \\#define PHYSAC_IMPLEMENTATION
        \\#define PHYSAC_STANDALONE
        \\#include "physac.h"
    );
    lib.step.dependOn(&gen_step.step);

    lib.linkLibC();
    lib.addIncludePath(physac_c_dep.path("src"));
    lib.addCSourceFile(.{ .file = physac_c_path });
    lib.installHeader(physac_c_dep.path("src/physac.h"), "physac.h");

    b.installArtifact(lib);

    const module = b.addModule("physac", .{
        .root_source_file = b.path("lib/physac.zig"),
        .target = target,
        .optimize = optimize,
    });

    module.addIncludePath(physac_c_dep.path("src"));
    module.linkLibrary(lib);

    const physac_test = b.addTest(.{
        .root_source_file = b.path("lib/physac.zig"),
        .target = target,
        .optimize = optimize,
    });
    physac_test.linkLibC();

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&physac_test.step);
}
