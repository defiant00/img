const std = @import("std");

pub fn RingBuffer(comptime T: type, comptime size: usize) type {
    if (!std.math.isPowerOfTwo(size)) @compileError("size must be a power of two");

    return struct {
        const Self = @This();

        buffer: [size]T = [_]T{0} ** size,
        index: usize = 0,

        pub fn add(self: *Self, item: T) void {
            self.buffer[self.index] = item;
            self.index = (self.index + 1) & (size - 1);
        }

        pub fn indexOf(self: *Self, item: T) ?usize {
            var i: usize = 0;
            while (i < size) : (i += 1) {
                if (self.buffer[i] == item) return i;
            }
            return null;
        }

        pub fn print(self: *Self) void {
            std.debug.print("{d}", .{self.buffer[0]});
            for (self.buffer[1..]) |i| {
                std.debug.print(", {d}", .{i});
            }
            std.debug.print("\n", .{});
        }
    };
}
