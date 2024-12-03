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
        if (reportIsSafe(report)) sum += 1;
    }
    std.debug.print("{}\n", .{sum});
}

pub fn partTwo(input: *Input) void {
    var sum: i32 = 0;
    for (input.reports.constSlice()) |report| {
        if (reportIsSafeLoosened(report)) sum += 1;
    }
    std.debug.print("{}\n", .{sum});
}

pub fn reportIsSafe(report: Report) bool {
    var increasing = false;
    if (report.get(1) > report.get(0)) increasing = true;
    for (0..report.len - 1) |idx| {
        if ((increasing and report.get(idx + 1) <= report.get(idx)) or (!increasing and report.get(idx + 1) >= report.get(idx))) return false;
        if (@abs(report.get(idx + 1) - report.get(idx)) > 3) return false;
    }
    return true;
}

const Tuple = struct { left: usize, right: usize };

pub fn reportIsSafeLoosened(report: Report) bool {
    var increasing_count: u32 = 0;
    var decreasing_count: u32 = 0;
    var violating_tuples: [2]Tuple = undefined;
    var violations: usize = 0;
    for (0..report.len - 1) |i| {
        if (report.get(i) < report.get(i + 1)) {
            increasing_count += 1;
        } else if (report.get(i) > report.get(i + 1)) {
            decreasing_count += 1;
        }
    }
    const increasing: bool = if (increasing_count >= report.len - 2) true else if (decreasing_count >= report.len - 2) false else return false;
    for (0..report.len - 1) |i| {
        if (report.get(i) == report.get(i + 1) or (increasing and report.get(i) > report.get(i + 1)) or (!increasing and report.get(i) < report.get(i + 1))) {
            if (violations >= 2) return false;
            violating_tuples[violations] = Tuple{ .left = i, .right = i + 1 };
            violations += 1;
        } else {
            const diff = @abs(report.get(i) - report.get(i + 1));
            if (diff < 1 or diff > 3) {
                if (violations >= 2) return false;
                violating_tuples[violations] = Tuple{ .left = i, .right = i + 1 };
                violations += 1;
            }
        }
    }
    if (violations == 0) return true;
    if (violations == 1) {
        const violation = violating_tuples[0];
        if (violation.left == 0 or violation.right == report.len - 1) return true;
        if (tupleIsValid(report, increasing, Tuple{ .left = violation.left - 1, .right = violation.right }) or tupleIsValid(report, increasing, Tuple{ .left = violation.left, .right = violation.right + 1 })) return true;
        return false;
    }
    if (violations == 2) {
        const violation1 = violating_tuples[0];
        const violation2 = violating_tuples[1];
        if (violation1.right != violation2.left) return false;
        if (tupleIsValid(report, increasing, Tuple{ .left = violation1.left, .right = violation1.left + 2 })) return true;
    }
    return false;
}

pub fn tupleIsValid(report: Report, increasing: bool, tuple: Tuple) bool {
    const difference = @abs(report.get(tuple.left) - report.get(tuple.right));
    if (difference < 1 or difference > 3) return false;
    if ((increasing and report.get(tuple.left) < report.get(tuple.right)) or (!increasing and report.get(tuple.left) > report.get(tuple.right))) return true;
    return false;
}
