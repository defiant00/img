const std = @import("std");
const img = @import("zigimg");

const RingBuffer = @import("ring_buffer.zig").RingBuffer;

// zig build run -- c:\git\test_images\

pub fn main() !void {
    std.debug.print("Image Encoding Test 0.0.1\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    _ = args.next(); // skip program name

    const png = ".png";
    const qoi = ".qoi";
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
                const png_path = buf[0 .. path.len + entry.name.len];
                const png_file = try std.fs.openFileAbsolute(png_path, .{});
                defer png_file.close();
                const png_size = (try png_file.stat()).size * 8;
                var image = try img.Image.fromFilePath(allocator, png_path);
                defer image.deinit();

                // get qoi size
                const no_ext_len = entry.name.len - png.len;
                std.mem.copy(u8, buf[0..], path);
                std.mem.copy(u8, buf[path.len..], entry.name[0..no_ext_len]);
                std.mem.copy(u8, buf[path.len + no_ext_len ..], qoi);
                const qoi_path = buf[0 .. path.len + no_ext_len + qoi.len];
                const qoi_file = try std.fs.openFileAbsolute(qoi_path, .{});
                defer qoi_file.close();
                const qoi_size = (try qoi_file.stat()).size * 8;

                const unc_channel = image.width * image.height * 8;
                const uncompressed = unc_channel * 4;

                var c1 = C1(u1, u1){};
                var c2 = C1(u1, u2){};
                var c3 = C1(u1, u3){};
                var c4 = C1(u1, u4){};
                var c5 = C1(u1, u5){};
                var c6 = C1(u1, u6){};
                var c7 = C2(u2, u4, u3){};
                var c8 = C2(u2, u4, u4){};
                var c9 = C2(u2, u4, u5){};
                var c10 = C2(u2, u4, u6){};
                var c11 = C2(u2, u4, u7){};
                var c12 = C2(u2, u4, u8){};

                var ci = image.iterator();
                while (ci.next()) |color| {
                    const c = color.toRgba32();
                    c1.add(c.r, c.g, c.b, c.a);
                    c2.add(c.r, c.g, c.b, c.a);
                    c3.add(c.r, c.g, c.b, c.a);
                    c4.add(c.r, c.g, c.b, c.a);
                    c5.add(c.r, c.g, c.b, c.a);
                    c6.add(c.r, c.g, c.b, c.a);
                    c7.add(c.r, c.g, c.b, c.a);
                    c8.add(c.r, c.g, c.b, c.a);
                    c9.add(c.r, c.g, c.b, c.a);
                    c10.add(c.r, c.g, c.b, c.a);
                    c11.add(c.r, c.g, c.b, c.a);
                    c12.add(c.r, c.g, c.b, c.a);
                }

                std.debug.print("       un: {d}\n", .{uncompressed});
                std.debug.print("      png: {d}\n", .{png_size});
                std.debug.print("      qoi: {d}\n", .{qoi_size});
                c1.print(" c1");
                c2.print(" c2");
                c3.print(" c3");
                c4.print(" c4");
                c5.print(" c5");
                c6.print(" c6");
                c7.print(" c7");
                c8.print(" c8");
                c9.print(" c9");
                c10.print("c10");
                c11.print("c11");
                c12.print("c12");
            }
        }
    }
}

fn C1(comptime op_t: type, comptime index_t: type) type {
    return struct {
        const Self = @This();
        const Channel = C1Channel(op_t, index_t);

        r: Channel = Channel{},
        g: Channel = Channel{},
        b: Channel = Channel{},
        a: Channel = Channel{},

        fn add(self: *Self, rv: u8, gv: u8, bv: u8, av: u8) void {
            self.r.add(rv);
            self.g.add(gv);
            self.b.add(bv);
            self.a.add(av);
        }

        fn print(self: *Self, label: []const u8) void {
            const total_size = self.r.size() + self.g.size() + self.b.size() + self.a.size();
            const total_full = self.r.full + self.g.full + self.b.full + self.a.full;
            const total_indexed = self.r.indexed + self.g.indexed + self.b.indexed + self.a.indexed;
            std.debug.print("      {s}: {d} ({d}, {d})\n", .{ label, total_size, total_full, total_indexed });
        }
    };
}

fn C1Channel(comptime op_t: type, comptime index_t: type) type {
    return struct {
        const Self = @This();
        const op_bits = @bitSizeOf(op_t);
        const index_bits = @bitSizeOf(index_t);
        const buf_size = std.math.maxInt(index_t) + 1;

        full: usize = 0,
        indexed: usize = 0,
        buf: RingBuffer(u8, buf_size) = RingBuffer(u8, buf_size){},

        fn add(self: *Self, val: u8) void {
            if (self.buf.indexOf(val)) |_| {
                self.indexed += 1;
            } else {
                self.full += 1;
                self.buf.add(val);
            }
        }

        fn size(self: *Self) usize {
            return self.full * (op_bits + 8) + self.indexed * (op_bits + index_bits);
        }
    };
}

fn C2(comptime op_t: type, comptime index_t: type, comptime rep_t: type) type {
    return struct {
        const Self = @This();
        const Channel = C2Channel(op_t, index_t, rep_t);

        r: Channel = Channel{},
        g: Channel = Channel{},
        b: Channel = Channel{},
        a: Channel = Channel{},

        fn add(self: *Self, rv: u8, gv: u8, bv: u8, av: u8) void {
            self.r.add(rv);
            self.g.add(gv);
            self.b.add(bv);
            self.a.add(av);
        }

        fn print(self: *Self, label: []const u8) void {
            self.r.finish();
            self.g.finish();
            self.b.finish();
            self.a.finish();

            const total_size = self.r.size() + self.g.size() + self.b.size() + self.a.size();
            const total_full = self.r.full + self.g.full + self.b.full + self.a.full;
            const total_indexed = self.r.indexed + self.g.indexed + self.b.indexed + self.a.indexed;
            const total_rep = self.r.repeat + self.g.repeat + self.b.repeat + self.a.repeat;
            std.debug.print("      {s}: {d} ({d}, {d}, {d})\n", .{ label, total_size, total_full, total_indexed, total_rep });
        }
    };
}

fn C2Channel(comptime op_t: type, comptime index_t: type, comptime rep_t: type) type {
    return struct {
        const Self = @This();
        const op_bits = @bitSizeOf(op_t);
        const index_bits = @bitSizeOf(index_t);
        const buf_size = std.math.maxInt(index_t) + 1;
        const rep_bits = @bitSizeOf(rep_t);
        const max_rep = std.math.maxInt(rep_t);

        prior: u8 = 0,
        cur_rep: rep_t = 0,
        full: usize = 0,
        indexed: usize = 0,
        repeat: usize = 0,
        buf: RingBuffer(u8, buf_size) = RingBuffer(u8, buf_size){},

        fn add(self: *Self, val: u8) void {
            if (self.prior == val) {
                self.cur_rep += 1;
                if (self.cur_rep == max_rep) {
                    self.repeat += 1;
                    self.cur_rep = 0;
                }
            } else {
                self.prior = val;
                if (self.cur_rep > 0) {
                    self.repeat += 1;
                    self.cur_rep = 0;
                }
                if (self.buf.indexOf(val)) |_| {
                    self.indexed += 1;
                } else {
                    self.full += 1;
                    self.buf.add(val);
                }
            }
        }

        fn finish(self: *Self) void {
            if (self.cur_rep > 0) {
                self.cur_rep = 0;
                self.repeat += 1;
            }
        }

        fn size(self: *Self) usize {
            return self.full * (op_bits + 8) + self.indexed * (op_bits + index_bits) + self.repeat * (op_bits + rep_bits);
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
