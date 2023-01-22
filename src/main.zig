const std = @import("std");
const img = @import("zigimg");

const RingBuffer = @import("ring_buffer.zig").RingBuffer;

// zig build run -- c:\git\test_images\
// https://qoiformat.org/

pub fn main() !void {
    std.debug.print("Image Encoding Test 0.0.1\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    _ = args.next(); // skip program name

    const png = ".png";
    // const ext = ".zimg";
    var buf: [1024]u8 = undefined;

    while (args.next()) |path| {
        std.debug.print("  {s}\n", .{path});
        var dir = try std.fs.openIterableDirAbsolute(path, .{});
        defer dir.close();
        var iter = dir.iterate();
        while (try iter.next()) |entry| {
            if (entry.kind == .File and std.mem.endsWith(u8, entry.name, png)) {
                std.debug.print("    {s}\n", .{entry.name});

                // load image
                std.mem.copy(u8, buf[0..], path);
                std.mem.copy(u8, buf[path.len..], entry.name);
                var image = try img.Image.fromFilePath(allocator, buf[0 .. path.len + entry.name.len]);
                defer image.deinit();

                const unc_channel = image.width * image.height * 8;
                const uncompressed = unc_channel * 4;

                var c1_r = C1(1, 9, 1){};
                var c1_g = C1(1, 9, 1){};
                var c1_b = C1(1, 9, 1){};
                var c1_a = C1(1, 9, 1){};

                var c2_r = C1(2, 9, 2){};
                var c2_g = C1(2, 9, 2){};
                var c2_b = C1(2, 9, 2){};
                var c2_a = C1(2, 9, 2){};

                var c3_r = C1(4, 9, 3){};
                var c3_g = C1(4, 9, 3){};
                var c3_b = C1(4, 9, 3){};
                var c3_a = C1(4, 9, 3){};

                var c4_r = C1(8, 9, 4){};
                var c4_g = C1(8, 9, 4){};
                var c4_b = C1(8, 9, 4){};
                var c4_a = C1(8, 9, 4){};

                var c5_r = C1(16, 9, 5){};
                var c5_g = C1(16, 9, 5){};
                var c5_b = C1(16, 9, 5){};
                var c5_a = C1(16, 9, 5){};

                var c6_r = C1(32, 9, 6){};
                var c6_g = C1(32, 9, 6){};
                var c6_b = C1(32, 9, 6){};
                var c6_a = C1(32, 9, 6){};

                var ci = image.iterator();
                while (ci.next()) |color| {
                    const c = color.toRgba32();

                    c1_r.add(c.r);
                    c1_g.add(c.g);
                    c1_b.add(c.b);
                    c1_a.add(c.a);

                    c2_r.add(c.r);
                    c2_g.add(c.g);
                    c2_b.add(c.b);
                    c2_a.add(c.a);

                    c3_r.add(c.r);
                    c3_g.add(c.g);
                    c3_b.add(c.b);
                    c3_a.add(c.a);

                    c4_r.add(c.r);
                    c4_g.add(c.g);
                    c4_b.add(c.b);
                    c4_a.add(c.a);

                    c5_r.add(c.r);
                    c5_g.add(c.g);
                    c5_b.add(c.b);
                    c5_a.add(c.a);

                    c6_r.add(c.r);
                    c6_g.add(c.g);
                    c6_b.add(c.b);
                    c6_a.add(c.a);
                }

                std.debug.print("      un: {d}\n", .{uncompressed});
                std.debug.print("      c1: {d}\n", .{c1_r.size() + c1_g.size() + c1_b.size() + c1_a.size()});
                std.debug.print("      c2: {d}\n", .{c2_r.size() + c2_g.size() + c2_b.size() + c2_a.size()});
                std.debug.print("      c3: {d}\n", .{c3_r.size() + c3_g.size() + c3_b.size() + c3_a.size()});
                std.debug.print("      c4: {d}\n", .{c4_r.size() + c4_g.size() + c4_b.size() + c4_a.size()});
                std.debug.print("      c5: {d}\n", .{c5_r.size() + c5_g.size() + c5_b.size() + c5_a.size()});
                std.debug.print("      c6: {d}\n", .{c6_r.size() + c6_g.size() + c6_b.size() + c6_a.size()});
                std.debug.print("      r\n", .{});
                std.debug.print("        un: {d}\n", .{unc_channel});
                std.debug.print("        c1: {d}\n", .{c1_r.size()});
                std.debug.print("        c2: {d}\n", .{c2_r.size()});
                std.debug.print("        c3: {d}\n", .{c3_r.size()});
                std.debug.print("        c4: {d}\n", .{c4_r.size()});
                std.debug.print("        c5: {d}\n", .{c5_r.size()});
                std.debug.print("        c6: {d}\n", .{c6_r.size()});
                std.debug.print("      g\n", .{});
                std.debug.print("        un: {d}\n", .{unc_channel});
                std.debug.print("        c1: {d}\n", .{c1_g.size()});
                std.debug.print("        c2: {d}\n", .{c2_g.size()});
                std.debug.print("        c3: {d}\n", .{c3_g.size()});
                std.debug.print("        c4: {d}\n", .{c4_g.size()});
                std.debug.print("        c5: {d}\n", .{c5_g.size()});
                std.debug.print("        c6: {d}\n", .{c6_g.size()});
                std.debug.print("      b\n", .{});
                std.debug.print("        un: {d}\n", .{unc_channel});
                std.debug.print("        c1: {d}\n", .{c1_b.size()});
                std.debug.print("        c2: {d}\n", .{c2_b.size()});
                std.debug.print("        c3: {d}\n", .{c3_b.size()});
                std.debug.print("        c4: {d}\n", .{c4_b.size()});
                std.debug.print("        c5: {d}\n", .{c5_b.size()});
                std.debug.print("        c6: {d}\n", .{c6_b.size()});
                std.debug.print("      a\n", .{});
                std.debug.print("        un: {d}\n", .{unc_channel});
                std.debug.print("        c1: {d}\n", .{c1_a.size()});
                std.debug.print("        c2: {d}\n", .{c2_a.size()});
                std.debug.print("        c3: {d}\n", .{c3_a.size()});
                std.debug.print("        c4: {d}\n", .{c4_a.size()});
                std.debug.print("        c5: {d}\n", .{c5_a.size()});
                std.debug.print("        c6: {d}\n", .{c6_a.size()});
            }
        }
    }
}

fn C1(comptime buf_size: usize, comptime full_size: usize, comptime indexed_size: usize) type {
    return struct {
        const Self = @This();

        full: usize = 0,
        indexed: usize = 0,
        buf: RingBuffer(u8, buf_size) = RingBuffer(u8, buf_size){},

        pub fn size(self: *Self) usize {
            return self.full * full_size + self.indexed * indexed_size;
        }

        pub fn add(self: *Self, val: u8) void {
            if (self.buf.indexOf(val)) |_| {
                self.indexed += 1;
            } else {
                self.full += 1;
                self.buf.add(val);
            }
        }
    };
}

// // save image
// const name_len = entry.name.len - png.len;
// std.mem.copy(u8, buf[0..], entry.name[0..name_len]);
// std.mem.copy(u8, buf[name_len..], ext);
// const file = try dir.dir.createFile(buf[0 .. name_len + ext.len], .{});
// defer file.close();
// var buffer = std.io.bufferedWriter(file.writer());
// const writer = buffer.writer();

// // magic bytes
// try writer.writeAll("zimg");
// // width
// try writer.writeInt(u32, @intCast(u32, image.width), .Little);
// // height
// try writer.writeInt(u32, @intCast(u32, image.height), .Little);
// // channels
// try writer.writeByte(3);
// // colorspace
// try writer.writeByte(0);

// try buffer.flush();
