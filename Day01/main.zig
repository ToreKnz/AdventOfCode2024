const std = @import("std");
const Input = struct {
    left: List(i32),
    right: List(i32),
};

pub fn List(comptime T: type) type {
    return std.BoundedArray(T, 1000);
}

pub fn main() !void {
    var input = try parseInput();
    partOne(&input);
    partTwo(&input);
}

pub fn parseInput() !Input {
    const input = try std.fs.cwd().openFile("Day01/input.txt", .{});
    defer input.close();
    var input_reader = std.io.bufferedReader(input.reader());
    var input_stream = input_reader.reader();
    var buffer: [1024]u8 = undefined;
    var left = List(i32).init(0) catch unreachable;
    var right = List(i32).init(0) catch unreachable;
    while (try input_stream.readUntilDelimiterOrEof(&buffer, '\n')) |nums| {
        const first_white = std.mem.indexOfScalar(u8, nums, ' ') orelse return error.InputFormatError;
        const left_num = try std.fmt.parseInt(i32, nums[0..first_white], 10);
        const right_num = try std.fmt.parseInt(i32, nums[first_white + 3 ..], 10);
        left.append(left_num) catch unreachable;
        right.append(right_num) catch unreachable;
    }
    return Input{ .left = left, .right = right };
}

pub fn partOne(input: *Input) void {
    std.mem.sort(i32, input.left.slice(), {}, lessThan);
    std.mem.sort(i32, input.right.slice(), {}, lessThan);
    var sum: u32 = 0;
    for (input.left.slice(), input.right.slice()) |a, b| {
        sum += @abs(a - b);
    }
    std.debug.print("{}\n", .{sum});
}

pub fn partTwo(input: *Input) void {
    var sum: u32 = 0;
    var map: [100_000]u8 = std.mem.zeroes([100_000]u8);
    for (input.right.slice()) |val| {
        map[@as(usize, @intCast(val))] += 1;
    }
    for (input.left.slice()) |a| {
        sum += map[@as(usize, @intCast(a))] * @as(u32, @intCast(a));
    }
    std.debug.print("{}\n", .{sum});
}

pub fn lessThan(_: void, a: i32, b: i32) bool {
    return a < b;
}
