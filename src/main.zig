const std = @import("std");
const img = @import("zigimg");

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
            }
        }
    }
}
