const std = @import("std");

const mem = std.mem;
const process = std.process;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const x11 = b.option(bool, "x11", "Use X11") orelse false;

    const lib = b.addLibrary(.{
        .name = "glfw",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true
        })
    });
    lib.root_module.addIncludePath(b.path("include"));
    lib.installHeadersDirectory(b.path("include/GLFW"), "GLFW", .{});

    lib.root_module.addCSourceFiles(.{
        .files = &.{
            "src/context.c",
            "src/egl_context.c",
            "src/init.c",
            "src/input.c",
            "src/monitor.c",
            "src/null_init.c",
            "src/null_joystick.c",
            "src/null_window.c",
            "src/osmesa_context.c",
            "src/platform.c",
            "src/vulkan.c",
            "src/window.c"
        }
    });
    switch(target.result.os.tag) {
        .windows => {
            lib.root_module.linkSystemLibrary("gdi32", .{});
            lib.root_module.linkSystemLibrary("user32", .{});
            lib.root_module.linkSystemLibrary("shell32", .{});

            lib.root_module.addCMacro("_GLFW_WIN32", "1");
            lib.root_module.addCSourceFiles(.{
                .files = &.{
                    "src/wgl_context.c",
                    "src/win32_init.c",
                    "src/win32_joystick.c",
                    "src/win32_module.c",
                    "src/win32_thread.c",
                    "src/win32_time.c",
                    "src/win32_window.c"
                }
            });
        },
        .macos => {
            lib.root_module.linkFramework("CFNetwork", .{});
            lib.root_module.linkFramework("ApplicationServices", .{});
            lib.root_module.linkFramework("ColorSync", .{});
            lib.root_module.linkFramework("CoreText", .{});
            lib.root_module.linkFramework("ImageIO", .{});

            lib.root_module.linkSystemLibrary("objc", .{});
            lib.root_module.linkFramework("IOKit", .{});
            lib.root_module.linkFramework("CoreFoundation", .{});
            lib.root_module.linkFramework("AppKit", .{});
            lib.root_module.linkFramework("CoreServices", .{});
            lib.root_module.linkFramework("CoreGraphics", .{});
            lib.root_module.linkFramework("Foundation", .{});
            lib.root_module.linkFramework("QuartzCore", .{});

            lib.root_module.addCMacro("_GLFW_COCOA", "1");
            lib.root_module.addCSourceFiles(.{
                .files = &.{
                    "src/cocoa_time.c",
                    "src/posix_module.c",
                    "src/posix_thread.c",
                    "src/cocoa_init.m",
                    "src/cocoa_joystick.m",
                    "src/cocoa_monitor.m",
                    "src/cocoa_window.m",
                    "src/nsgl_context.m",
                }
            });
        },
        else => {
            lib.root_module.addCSourceFiles(.{
                .files = &.{
                    "src/linux_joystick.c",
                    "src/posix_module.c",
                    "src/posix_poll.c",
                    "src/posix_thread.c",
                    "src/posix_time.c",
                    "src/xkb_unicode.c",
                }
            });

            if (x11) {
                lib.root_module.addCMacro("_GLFW_X11", "1");
                lib.root_module.addCSourceFiles(.{
                    .files = &.{
                        "src/glx_context.c",
                        "src/x11_init.c",
                        "src/x11_monitor.c",
                        "src/x11_window.c"
                    }
                });
            } else {
                lib.root_module.addCMacro("_GLFW_WAYLAND", "1");
                lib.root_module.addCSourceFiles(.{
                    .files = &.{
                        "src/wl_init.c",
                        "src/wl_monitor.c",
                        "src/wl_window.c"
                    },
                    .flags = &.{
                        "-Wno-implicit-function-declaration",
                    },
                });
            }
        }
    }
    b.installArtifact(lib);
}