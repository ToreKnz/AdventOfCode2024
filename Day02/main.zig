const std = @import("std");

const Input = struct {
    reports: List(Report),
};

const Report = std.BoundedArray(i32, 10);

pub fn List(comptime T: type) type {
    return std.BoundedArray(T, 1000);
}

pub fn main() !void {
    var input = try parseInput();
    partOne(&input);
    partTwo(&input);
}

pub fn parseInput() !Input {
    const input = try std.fs.cwd().openFile("Day02/input.txt", .{});
    defer input.close();
    var input_reader = std.io.bufferedReader(input.reader());
    var input_stream = input_reader.reader();
    var buffer: [1024]u8 = undefined;
    var reports = List(Report).init(0) catch unreachable;
    while (try input_stream.readUntilDelimiterOrEof(&buffer, '\n')) |nums| {
        var report = Report.init(0) catch unreachable;
        var splits = std.mem.splitScalar(u8, nums, ' ');
        while (splits.next()) |num_str| {
            const num = try std.fmt.parseInt(i32, num_str, 10);
            report.append(num) catch unreachable;
        }
        reports.append(report) catch unreachable;
    }
    return Input{ .reports = reports };
}

pub fn partOne(input: *Input) void {
    var sum: i32 = 0;
    for (input.reports.constSlice()) |report| {
        if (reportIsSafe(report, false, 0)) sum += 1;
    }
    std.debug.print("{}\n", .{sum});
}

pub fn partTwo(input: *Input) void {
    var sum: i32 = 0;
    outer: for (input.reports.constSlice()) |report| {
        if (reportIsSafe(report, false, 0)) {
            sum += 1;
            continue;
        }
        for (0..report.len) |idx| {
            if (reportIsSafe(report, true, idx)) {
                sum += 1;
                continue :outer;
            }
        }
    }
    std.debug.print("{}\n", .{sum});
}

pub fn reportIsSafe(report: Report, comptime skip: bool, skip_index: usize) bool {
    if (comptime !skip) {
        var increasing = false;
        if (report.get(1) > report.get(0)) increasing = true;
        for (0..report.len - 1) |idx| {
            if ((increasing and report.get(idx + 1) <= report.get(idx)) or (!increasing and report.get(idx + 1) >= report.get(idx))) return false;
            if (@abs(report.get(idx + 1) - report.get(idx)) > 3) return false;
        }
        return true;
    }
    var increasing = false;
    var left_idx: usize = 0;
    var right_idx: usize = 1;
    if (skip_index < 2) {
        left_idx = 2;
        right_idx = 3;
    }
    if (report.get(right_idx) > report.get(left_idx)) increasing = true;
    for (0..report.len - 1) |idx| {
        left_idx = if (skip_index == idx) idx + 1 else idx;
        right_idx = if (skip_index == left_idx + 1) left_idx + 2 else left_idx + 1;
        if (right_idx > report.len - 1) break;
        if ((increasing and report.get(right_idx) <= report.get(left_idx)) or (!increasing and report.get(right_idx) >= report.get(left_idx))) return false;
        if (@abs(report.get(right_idx) - report.get(left_idx)) > 3) return false;
    }
    return true;
}
