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

    lib.linkLibC();
    lib.addIncludePath(physac_c_dep.path("src"));
    lib.addCSourceFile(.{
        .file = physac_c_dep.path("src/physac.h"),
        .flags = &.{
            "-DPHYSAC_IMPLEMENTATION",
            "-DPHYSAC_STANDALONE",
        },
    });

    b.installArtifact(lib);

    const module = b.addModule("physac", .{
        .root_source_file = b.path("lib/physac.zig"),
        .target = target,
        .optimize = optimize,
    });

    module.addIncludePath(physac_c_dep.path("src"));

    const physac_test = b.addTest(.{
        .root_source_file = b.path("lib/physac.zig"),
        .target = target,
        .optimize = optimize,
    });
    physac_test.linkLibC();

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&physac_test.step);
}
