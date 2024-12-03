const std = @import("std");
const day01 = @import("Day01/main.zig");
const day02 = @import("Day02/main.zig");
const day03 = @import("Day03/main.zig");

pub fn main() !void {
    const first_problem = 1;
    const last_problem = 3;
    inline for (first_problem..last_problem + 1) |i| {
        const number = std.fmt.comptimePrint("{:0>2}", .{i});
        std.debug.print("Day {s}\n", .{number});
        try @field(@This(), "day" ++ number).main();
        std.debug.print("\n", .{});
    }
}