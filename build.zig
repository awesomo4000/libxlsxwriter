const std = @import("std");

const xlsxw_version: std.SemanticVersion = .{
    .major = 1,
    .minor = 1,
    .patch = 9,
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const shared = b.option(bool, "SHARED_LIBRARY", "Build the Shared Library [default: false]") orelse false;
    const examples = b.option(bool, "BUILD_EXAMPLES", "Build libxlsxwriter examples [default: false]") orelse false;
    const tests = b.option(bool, "BUILD_TESTS", "Build libxlsxwriter tests [default: false]") orelse false;
    const dtoa = b.option(bool, "USE_DTOA_LIBRARY", "Use the locale independent third party Milo Yip DTOA library [default: off]") orelse false;
    const md5 = b.option(bool, "USE_OPENSSL_MD5", "Build libxlsxwriter with the OpenSSL MD5 lib [default: off]") orelse false;
    const stdtmpfile = b.option(bool, "USE_STANDARD_TMPFILE", "Use the C standard library's tmpfile() [default: off]") orelse false;

    const lib = if (shared) b.addSharedLibrary(.{
        .name = "xlsxwriter",
        .target = target,
        .optimize = optimize,
        .version = xlsxw_version,
    }) else b.addStaticLibrary(.{
        .name = "xlsxwriter",
        .target = target,
        .optimize = optimize,
    });
    lib.pie = true;
    switch (optimize) {
        .Debug, .ReleaseSafe => lib.bundle_compiler_rt = true,
        else => lib.root_module.strip = true,
    }
    if (tests)
        lib.root_module.addCMacro("TESTING", "");
    lib.addCSourceFiles(.{
        .files = &.{
            "src/vml.c",
            "src/chartsheet.c",
            "src/theme.c",
            "src/content_types.c",
            "src/xmlwriter.c",
            "src/app.c",
            "src/styles.c",
            "src/core.c",
            "src/comment.c",
            "src/utility.c",
            "src/metadata.c",
            "src/custom.c",
            "src/hash_table.c",
            "src/relationships.c",
            "src/drawing.c",
            "src/chart.c",
            "src/shared_strings.c",
            "src/worksheet.c",
            "src/format.c",
            "src/table.c",
            "src/workbook.c",
            "src/packager.c",
            "src/rich_value.c",
            "src/rich_value_rel.c",
            "src/rich_value_structure.c",
            "src/rich_value_types.c",
        },
        .flags = cflags,
    });

    // zlib
    lib.addCSourceFiles(.{
        .files = &.{
            "deps/zlib/adler32.c",
            "deps/zlib/compress.c",
            "deps/zlib/crc32.c",
            "deps/zlib/deflate.c",
            "deps/zlib/infback.c",
            "deps/zlib/inffast.c",
            "deps/zlib/inflate.c",
            "deps/zlib/inftrees.c",
            "deps/zlib/trees.c",
            "deps/zlib/uncompr.c",
            "deps/zlib/zutil.c",
        },
        .flags = zlib_cflags,
    });

    // minizip
    lib.linkLibC();
    lib.addCSourceFiles(.{
        .files = switch (lib.rootModuleTarget().os.tag) {
            .windows => minizip_src ++ [_][]const u8{
                "third_party/minizip/iowin32.c",
            },
            else => minizip_src,
        },
        .flags = cflags,
    });

    // md5
    if (!md5)
        lib.addCSourceFile(.{
            .file = b.path("third_party/md5/md5.c"),
            .flags = cflags,
        });

    // dtoa
    if (dtoa)
        lib.addCSourceFile(.{
            .file = b.path("third_party/dtoa/emyg_dtoa.c"),
            .flags = cflags,
        });

    // tmpfileplus
    if (stdtmpfile)
        lib.addCSourceFile(.{
            .file = b.path("third_party/tmpfileplus/tmpfileplus.c"),
            .flags = cflags,
        })
    else
        lib.root_module.addCMacro("USE_STANDARD_TMPFILE", "");

    lib.addIncludePath(b.path("include"));
    lib.addIncludePath(b.path("third_party"));
    lib.addIncludePath(b.path("deps/zlib"));
    lib.linkLibC();

    // get headers on include to zig-out/include
    lib.installHeadersDirectory(b.path("include"), "", .{});

    // get binaries on zig-cache to zig-out
    b.installArtifact(lib);

    // build examples
    if (examples) {
        buildExe(b, .{
            .lib = lib,
            .path = "anatomy.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "array_formula.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "autofilter.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "background.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "chart.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "chart_area.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "chart_bar.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "chart_clustered.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "chart_column.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "chart_data_labels.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "chart_data_table.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "chart_data_tools.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "chart_doughnut.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "chart_fonts.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "chart_line.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "chart_pattern.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "chart_pie.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "chart_pie_colors.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "chart_radar.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "chart_scatter.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "chart_styles.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "chart_working_with_example.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "chartsheet.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "comments1.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "comments2.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "conditional_format1.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "conditional_format2.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "constant_memory.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "data_validate.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "dates_and_times01.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "dates_and_times02.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "dates_and_times03.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "dates_and_times04.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "defined_name.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "demo.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "diagonal_border.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "doc_custom_properties.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "doc_properties.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "dynamic_arrays.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "embed_image_buffer.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "embed_images.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "format_font.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "format_num_format.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "headers_footers.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "hello.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "hide_row_col.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "hide_sheet.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "hyperlinks.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "ignore_errors.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "image_buffer.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "images.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "lambda.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "macro.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "merge_range.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "merge_rich_string.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "outline.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "outline_collapsed.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "output_buffer.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "panes.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "rich_strings.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "tab_colors.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "tables.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "tutorial1.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "tutorial2.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "tutorial3.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "utf8.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "watermark.c",
        });

        buildExe(b, .{
            .lib = lib,
            .path = "worksheet_protection.c",
        });
    }
    // build tests
    if (tests) {
        buildTest(b, .{
            .lib = lib,
            .path = "test/unit/app/test_app.c",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/unit/chart/test_chart.c",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/unit/chartsheet/test_chartsheet.c",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/unit/content_types/test_content_types.c",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/unit/content_types/test_content_types_write_default.c",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/unit/content_types/test_content_types_write_override.c",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/unit/relationships/test_relationships.c",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/unit/app/test_app_xml_declaration.c",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/unit/relationships/test_relationships_xml_declaration.c",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/unit/custom/test_custom_xml_declaration.c",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/unit/metadata/test_metadata_xml_declaration.c",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/unit/core/test_core_xml_declaration.c",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/unit/sst/test_shared_strings.c",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/unit/workbook/test_workbook.c",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/unit/xmlwriter/test_xmlwriter.c",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/unit/table/test_table01.c",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/unit/table/test_table02.c",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/unit/table/test_table03.c",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/unit/table/test_table04.c",
        });
        buildTest(b, .{
            .lib = lib,
            .path = "test/unit/styles/test_styles_write_border.c",
        });
    }
}

fn buildExe(b: *std.Build, args: struct {
    lib: *std.Build.Step.Compile,
    path: []const u8,
}) void {
    const exe = b.addExecutable(.{
        .name = std.fs.path.stem(args.path),
        .target = args.lib.root_module.resolved_target.?,
        .optimize = args.lib.root_module.optimize.?,
    });
    const example_path = b.fmt("examples/{s}", .{args.path});
    exe.addCSourceFile(.{
        .file = b.path(example_path),
        .flags = cflags,
    });
    exe.linkLibrary(args.lib);
    exe.linkLibC();
    b.installArtifact(exe);
}

fn buildTest(b: *std.Build, info: BuildInfo) void {
    const exe = b.addExecutable(.{
        .name = info.filename(),
        .optimize = info.lib.root_module.optimize.?,
        .target = info.lib.root_module.resolved_target.?,
    });
    exe.root_module.addCMacro("TESTING", "");
    exe.addCSourceFile(.{
        .file = b.path(info.path),
        .flags = cflags,
    });
    exe.addCSourceFile(.{
        .file = b.path("test/unit/test_all.c"),
        .flags = cflags,
    });
    exe.addIncludePath(b.path("test/unit"));
    for (info.lib.root_module.include_dirs.items) |include| {
        exe.root_module.include_dirs.append(b.allocator, include) catch {};
    }
    exe.linkLibrary(info.lib);
    exe.linkLibC();
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step(
        b.fmt("{s}", .{info.filename()}),
        b.fmt("Run the {s} test", .{info.filename()}),
    );
    run_step.dependOn(&run_cmd.step);
}

const cflags: []const []const u8 = &[_][]const u8{
    "-std=c99",
    "-Wall",
    "-Wextra",
    "-Wno-unused-parameter",
};

const zlib_cflags: []const []const u8 = &[_][]const u8{
    "-std=c99",
    "-Wall",
    "-Wextra",
    "-Wno-unused-parameter",
    "-DHAVE_UNISTD_H",
    "-DHAVE_STDARG_H",
    "-DHAVE_VSNPRINTF",
    "-DHAVE_STRERROR",
    "-DHAVE_ATTRIBUTE_VISIBILITY",
    "-DHAVE_FSEEKO",
    "-DHAVE_VSNPRINTF_RETURN",
    "-DUSE_MMAP",
};

const minizip_src: []const []const u8 = &.{
    "third_party/minizip/ioapi.c",
    "third_party/minizip/mztools.c",
    "third_party/minizip/unzip.c",
    "third_party/minizip/zip.c",
};

const BuildInfo = struct {
    lib: *std.Build.Step.Compile,
    path: []const u8,

    fn filename(self: BuildInfo) []const u8 {
        var split = std.mem.splitSequence(u8, std.fs.path.basename(self.path), ".");
        return split.first();
    }
};
