const std = @import("std");

const Input = struct {
    lines_internal: std.BoundedArray([1024 * 20]u8, 10),
    lines_slices: std.BoundedArray([]u8, 10),
};

pub fn main() void {
    var input = parseInput();
    partOne(&input);
    partTwo(&input);
}

pub fn parseInput() Input {
    const input = std.fs.cwd().openFile("input.txt", .{}) catch unreachable;
    defer input.close();
    var input_reader = std.io.bufferedReader(input.reader());
    var input_stream = input_reader.reader();
    var buffer: [1024 * 20]u8 = undefined;
    var lines = std.BoundedArray([1024 * 20] u8, 10).init(0) catch unreachable;
    var line_slices = std.BoundedArray([]u8, 10).init(0) catch unreachable;
    while (input_stream.readUntilDelimiterOrEof(&buffer, '\n') catch unreachable) |line| {
        lines.append(buffer) catch unreachable;
        const slice = lines.slice()[lines.len - 1][0..line.len];
        line_slices.append(slice) catch unreachable;
    }
    return Input {.lines_internal = lines, .lines_slices = line_slices};
}

pub fn partOne(input: *Input) void {
    var sum: u32 = 0;
    for (input.lines_slices.constSlice()) |line| sum += lineMulSum(line, false, false);
    std.debug.print("{}\n", .{sum});
}

pub fn partTwo(input: *Input) void {
    var sum: u32 = 0;
    var do = true;
    for (input.lines_slices.constSlice()) |line| {
        const res = lineMulSum(line, true, do);
        do = res.do;
        sum += res.sum;
    }
    std.debug.print("{}\n", .{sum});
}

const SumDoResult = struct {
    sum: u32,
    do: bool,
};

pub fn lineMulSum(line: []const u8, comptime apply_dos: bool, do: bool) if (apply_dos) SumDoResult else u32 {
    var add = do;
    var splits = std.mem.splitSequence(u8, line, "mul(");
    var sum: u32 = 0;
    var idx: u32 = 0;
    while (splits.next()) |split| : (idx += 1){
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
        const comma_idx = std.mem.indexOfScalar(u8, split, ',') orelse continue;
        const bracket_idx = std.mem.indexOfScalar(u8, split, ')') orelse continue;
        if (comma_idx > bracket_idx) continue;
        const left = split[0..comma_idx];
        const right = split[comma_idx+1..bracket_idx];
        const left_num = std.fmt.parseInt(u32, left, 10) catch continue;
        const right_num = std.fmt.parseInt(u32, right, 10) catch continue;
        if (comptime apply_dos) {
            if (add) sum += left_num * right_num;
        } else {
            sum += left_num * right_num;
        }
    }
    if (comptime apply_dos) {
        return SumDoResult {.sum = sum, .do = add};
    }
    return sum;
}