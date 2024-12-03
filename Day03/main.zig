const std = @import("std");

const Input = struct {
    internal_buffer: [1024 * 100]u8,
    len: usize,

    fn getSlice(self: *Input) []const u8 {
        return self.internal_buffer[0..self.len];
    }
};

pub fn main() !void {
    var input = try parseInput();
    partOne(&input);
    partTwo(&input);
}

pub fn parseInput() !Input {
    const input = try std.fs.cwd().openFile("Day03/input.txt", .{});
    defer input.close();
    var input_reader = std.io.bufferedReader(input.reader());
    var input_stream = input_reader.reader();
    var buffer: [1024 * 100]u8 = undefined;
    const len = try input_stream.readAll(&buffer);
    return Input{ .internal_buffer = buffer, .len = len };
}

pub fn partOne(input: *Input) void {
    const sum = mulSum(input.getSlice(), false, false);
    std.debug.print("{}\n", .{sum});
}

pub fn partTwo(input: *Input) void {
    const sum = mulSum(input.getSlice(), true, true);
    std.debug.print("{}\n", .{sum});
}

pub fn mulSum(text: []const u8, comptime apply_dos: bool, do: bool) u32 {
    var add = do;
    var splits = std.mem.splitSequence(u8, text, "mul(");
    var sum: u32 = 0;
    var idx: u32 = 0;
    while (splits.next()) |split| : (idx += 1) {
        defer {
            if (comptime apply_dos) {
                const do_idx = std.mem.lastIndexOf(u8, split, "do()");
                const dont_idx = std.mem.lastIndexOf(u8, split, "don't()");
                if (do_idx != null and dont_idx != null) {
                    add = if (do_idx.? > dont_idx.?) true else false;
                } else if (do_idx != null or dont_idx != null) {
                    add = if (do_idx != null) true else false;
                }
            }
        }
        if (idx == 0) continue;
        const comma_idx = std.mem.indexOfScalar(u8, split[0..@min(split.len,4)], ',') orelse continue;
        const bracket_idx = std.mem.indexOfScalar(u8, split[0..@min(split.len,8)], ')') orelse continue;
        if (comma_idx > bracket_idx) continue;
        const left = split[0..comma_idx];
        const right = split[comma_idx + 1 .. bracket_idx];
        const left_num = std.fmt.parseInt(u32, left, 10) catch continue;
        const right_num = std.fmt.parseInt(u32, right, 10) catch continue;
        if (comptime apply_dos) {
            if (add) sum += left_num * right_num;
        } else {
            sum += left_num * right_num;
        }
    }
    return sum;
}
