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
    var counts: [256]usize = [_]usize{0} ** 256;

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

                var c1 = C2(u2, u4, u3, i3){};
                var c2 = C2(u2, u4, u4, i3){};
                var c3 = C2(u2, u4, u5, i3){};
                var c4 = C2(u2, u4, u6, i3){};
                var c5 = C2(u2, u4, u7, i3){};

                var c6 = C2(u2, u4, u3, i4){};
                var c7 = C2(u2, u4, u4, i4){};
                var c8 = C2(u2, u4, u5, i4){};
                var c9 = C2(u2, u4, u6, i4){};
                var c10 = C2(u2, u4, u7, i4){};

                var c11 = C2(u2, u4, u3, i5){};
                var c12 = C2(u2, u4, u4, i5){};
                var c13 = C2(u2, u4, u5, i5){};
                var c14 = C2(u2, u4, u6, i5){};
                var c15 = C2(u2, u4, u7, i5){};

                var c16 = C3(u2, u4, i3){};
                var c17 = C3(u2, u4, i4){};
                var c18 = C3(u2, u4, i5){};

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
                    c13.add(c.r, c.g, c.b, c.a);
                    c14.add(c.r, c.g, c.b, c.a);
                    c15.add(c.r, c.g, c.b, c.a);
                    c16.add(c.r, c.g, c.b, c.a);
                    c17.add(c.r, c.g, c.b, c.a);
                    c18.add(c.r, c.g, c.b, c.a);
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
                c13.print("c13");
                c14.print("c14");
                c15.print("c15");
                c16.print("c16");
                c17.print("c17");
                c18.print("c18");

                const sizes = [_]usize{
                    c1.size(),
                    c2.size(),
                    c3.size(),
                    c4.size(),
                    c5.size(),
                    c6.size(),
                    c7.size(),
                    c8.size(),
                    c9.size(),
                    c10.size(),
                    c11.size(),
                    c12.size(),
                    c13.size(),
                    c14.size(),
                    c15.size(),
                    c16.size(),
                    c17.size(),
                    c18.size(),
                };

                var min: usize = std.math.maxInt(usize);
                var idx: usize = 0;
                for (sizes) |s, i| {
                    if (s < min) {
                        min = s;
                        idx = i;
                    }
                }
                counts[idx] += 1;
            }
        }
    }

    std.debug.print("Counts:\n", .{});
    for (counts) |c, i| {
        if (c > 0) std.debug.print("  c{d}: {d}\n", .{ i + 1, c });
    }
}

fn C2(comptime op_t: type, comptime index_t: type, comptime rep_t: type, comptime diff_t: type) type {
    return struct {
        const Self = @This();
        const Channel = C2Channel(op_t, index_t, rep_t, diff_t);

        r: Channel = Channel{},
        g: Channel = Channel{},
        b: Channel = Channel{},
        a: Channel = Channel{},
        has_alpha: bool = false,

        fn add(self: *Self, rv: u8, gv: u8, bv: u8, av: u8) void {
            self.r.add(rv);
            self.g.add(gv);
            self.b.add(bv);
            self.a.add(av);
            if (av != 255) self.has_alpha = true;
        }

        fn print(self: *Self, label: []const u8) void {
            self.r.finish();
            self.g.finish();
            self.b.finish();
            self.a.finish();

            if (self.has_alpha) {
                const total_full = self.r.full + self.g.full + self.b.full + self.a.full;
                const total_indexed = self.r.indexed + self.g.indexed + self.b.indexed + self.a.indexed;
                const total_rep = self.r.repeat + self.g.repeat + self.b.repeat + self.a.repeat;
                const total_diff = self.r.diff + self.g.diff + self.b.diff + self.a.diff;
                std.debug.print("      {s}: {d} (full {d}, idx {d}, rep {d}, diff {d}) rgba\n", .{ label, self.size(), total_full, total_indexed, total_rep, total_diff });
            } else {
                const total_full = self.r.full + self.g.full + self.b.full;
                const total_indexed = self.r.indexed + self.g.indexed + self.b.indexed;
                const total_rep = self.r.repeat + self.g.repeat + self.b.repeat;
                const total_diff = self.r.diff + self.g.diff + self.b.diff;
                std.debug.print("      {s}: {d} (full {d}, idx {d}, rep {d}, diff {d}) rgba\n", .{ label, self.size(), total_full, total_indexed, total_rep, total_diff });
            }
        }

        fn size(self: *Self) usize {
            var s = self.r.size() + self.g.size() + self.b.size();
            if (self.has_alpha) s += self.a.size();
            return s;
        }
    };
}

fn C2Channel(comptime op_t: type, comptime index_t: type, comptime rep_t: type, comptime diff_t: type) type {
    return struct {
        const Self = @This();
        const op_bits = @bitSizeOf(op_t);
        const index_bits = @bitSizeOf(index_t);
        const buf_size = std.math.maxInt(index_t) + 1;
        const rep_bits = @bitSizeOf(rep_t);
        const max_rep = std.math.maxInt(rep_t);
        const diff_bits = @bitSizeOf(diff_t);

        prior: u8 = 0,
        cur_rep: rep_t = 0,
        full: usize = 0,
        indexed: usize = 0,
        repeat: usize = 0,
        diff: usize = 0,
        buf: RingBuffer(u8, buf_size) = RingBuffer(u8, buf_size){},

        fn add(self: *Self, val: u8) void {
            if (self.prior == val) {
                self.cur_rep += 1;
                if (self.cur_rep == max_rep) {
                    self.repeat += 1;
                    self.cur_rep = 0;
                }
            } else {
                if (self.cur_rep > 0) {
                    self.repeat += 1;
                    self.cur_rep = 0;
                }
                if (self.buf.indexOf(val)) |_| {
                    self.indexed += 1;
                } else {
                    const dist = distWithWrap(self.prior, val);
                    if ((dist >= std.math.minInt(diff_t)) and (dist <= std.math.maxInt(diff_t))) {
                        self.diff += 1;
                    } else {
                        self.full += 1;
                    }
                    self.buf.add(val);
                }
                self.prior = val;
            }
        }

        fn distWithWrap(prior: u8, cur: u8) isize {
            const forward = cur -% prior;
            const back = prior -% cur;
            return if (forward < back) forward else -@as(isize, back);
        }

        fn finish(self: *Self) void {
            if (self.cur_rep > 0) {
                self.cur_rep = 0;
                self.repeat += 1;
            }
        }

        fn size(self: *Self) usize {
            return self.full * (op_bits + 8) + self.indexed * (op_bits + index_bits) + self.repeat * (op_bits + rep_bits) + self.diff * (op_bits + diff_bits);
        }
    };
}

fn C3(comptime op_t: type, comptime index_t: type, comptime diff_t: type) type {
    return struct {
        const Self = @This();
        const Channel = C3Channel(op_t, index_t, diff_t);

        r: Channel = Channel{},
        g: Channel = Channel{},
        b: Channel = Channel{},
        a: Channel = Channel{},
        has_alpha: bool = false,

        fn add(self: *Self, rv: u8, gv: u8, bv: u8, av: u8) void {
            self.r.add(rv);
            self.g.add(gv);
            self.b.add(bv);
            self.a.add(av);
            if (av != 255) self.has_alpha = true;
        }

        fn print(self: *Self, label: []const u8) void {
            self.r.finish();
            self.g.finish();
            self.b.finish();
            self.a.finish();

            if (self.has_alpha) {
                const total_full = self.r.full + self.g.full + self.b.full + self.a.full;
                const total_indexed = self.r.indexed + self.g.indexed + self.b.indexed + self.a.indexed;
                const total_rep = self.r.repeat + self.g.repeat + self.b.repeat + self.a.repeat;
                const total_diff = self.r.diff + self.g.diff + self.b.diff + self.a.diff;
                std.debug.print("      {s}: {d} (full {d}, idx {d}, rep {d}, diff {d}) rgba\n", .{ label, self.size(), total_full, total_indexed, total_rep, total_diff });
            } else {
                const total_full = self.r.full + self.g.full + self.b.full;
                const total_indexed = self.r.indexed + self.g.indexed + self.b.indexed;
                const total_rep = self.r.repeat + self.g.repeat + self.b.repeat;
                const total_diff = self.r.diff + self.g.diff + self.b.diff;
                std.debug.print("      {s}: {d} (full {d}, idx {d}, rep {d}, diff {d}) rgba\n", .{ label, self.size(), total_full, total_indexed, total_rep, total_diff });
            }
        }

        fn size(self: *Self) usize {
            var s = self.r.size() + self.g.size() + self.b.size();
            if (self.has_alpha) s += self.a.size();
            return s;
        }
    };
}

fn C3Channel(comptime op_t: type, comptime index_t: type, comptime diff_t: type) type {
    return struct {
        const Self = @This();
        const op_bits = @bitSizeOf(op_t);
        const index_bits = @bitSizeOf(index_t);
        const buf_size = std.math.maxInt(index_t) + 1;
        const max_rep = std.math.maxInt(u25);
        const diff_bits = @bitSizeOf(diff_t);

        prior: u8 = 0,
        cur_rep: u25 = 0,
        full: usize = 0,
        indexed: usize = 0,
        repeat: usize = 0,
        repeat_bits: usize = 0,
        diff: usize = 0,
        buf: RingBuffer(u8, buf_size) = RingBuffer(u8, buf_size){},

        fn add(self: *Self, val: u8) void {
            if (self.prior == val) {
                self.cur_rep += 1;
                if (self.cur_rep == max_rep) {
                    self.addRepeat();
                }
            } else {
                if (self.cur_rep > 0) {
                    self.addRepeat();
                }
                if (self.buf.indexOf(val)) |_| {
                    self.indexed += 1;
                } else {
                    const dist = distWithWrap(self.prior, val);
                    if ((dist >= std.math.minInt(diff_t)) and (dist <= std.math.maxInt(diff_t))) {
                        self.diff += 1;
                    } else {
                        self.full += 1;
                    }
                    self.buf.add(val);
                }
                self.prior = val;
            }
        }

        // msb indicates continuation, size in bits per part: 4 8 8 8
        fn addRepeat(self: *Self) void {
            self.repeat += 1;
            if (self.cur_rep > std.math.maxInt(u17)) {
                self.repeat_bits += 28;
            } else if (self.cur_rep > std.math.maxInt(u10)) {
                self.repeat_bits += 20;
            } else if (self.cur_rep > std.math.maxInt(u3)) {
                self.repeat_bits += 12;
            } else {
                self.repeat_bits += 4;
            }
            self.cur_rep = 0;
        }

        fn distWithWrap(prior: u8, cur: u8) isize {
            const forward = cur -% prior;
            const back = prior -% cur;
            return if (forward < back) forward else -@as(isize, back);
        }

        fn finish(self: *Self) void {
            if (self.cur_rep > 0) {
                self.addRepeat();
            }
        }

        fn size(self: *Self) usize {
            return self.full * (op_bits + 8) +
                self.indexed * (op_bits + index_bits) +
                self.repeat * op_bits +
                self.repeat_bits +
                self.diff * (op_bits + diff_bits);
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
