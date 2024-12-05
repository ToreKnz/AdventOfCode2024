const std = @import("std");

const Input = struct {
    lines: std.ArrayList([]u8),

};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var input = try parseInput(allocator);
    partOne(&input);
    partTwo(&input);
}

pub fn parseInput(allocator: std.mem.Allocator) !Input {
    const input = try std.fs.cwd().openFile("Day04/input.txt", .{});
    defer input.close();
    var input_reader = std.io.bufferedReader(input.reader());
    var input_stream = input_reader.reader();
    var buffer: [1024]u8 = undefined;
    var lines = std.ArrayList([]u8).init(allocator);
    while (try input_stream.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        const line_cp = allocator.dupe(u8, line) catch unreachable;
        lines.append(line_cp) catch unreachable;
    }
    return Input {.lines = lines};
}

pub fn partOne(input: *Input) void {
    var xmas_count: u32 = 0;
    const lines = input.lines;
    for (lines.items) |line| {
        for (0..line.len - 3) |idx| {
            // horizontal
            if (std.mem.startsWith(u8, line[idx..], "XMAS") or std.mem.startsWith(u8, line[idx..], "SAMX")) xmas_count += 1;
        }
    }
    const cols = lines.items[0].len;
    for (0..cols) |col_idx| {
        for (0..lines.items.len) |row_idx| {
            // vertical
            if (row_idx < lines.items.len - 3) {
                if (lines.items[row_idx][col_idx] == 'X' and lines.items[row_idx + 1][col_idx] == 'M' and lines.items[row_idx + 2][col_idx] == 'A' and lines.items[row_idx + 3][col_idx] == 'S') xmas_count += 1
                else if (lines.items[row_idx][col_idx] == 'S' and lines.items[row_idx + 1][col_idx] == 'A' and lines.items[row_idx + 2][col_idx] == 'M' and lines.items[row_idx + 3][col_idx] == 'X') xmas_count += 1;
            }
            // diagonal down
            if (col_idx < cols - 3 and row_idx < lines.items.len - 3) {
               if (lines.items[row_idx][col_idx] == 'X' and lines.items[row_idx + 1][col_idx + 1] == 'M' and lines.items[row_idx + 2][col_idx + 2] == 'A' and lines.items[row_idx + 3][col_idx + 3] == 'S') xmas_count += 1
                else if (lines.items[row_idx][col_idx] == 'S' and lines.items[row_idx + 1][col_idx + 1] == 'A' and lines.items[row_idx + 2][col_idx + 2] == 'M' and lines.items[row_idx + 3][col_idx + 3] == 'X') xmas_count += 1; 
            }
            // diagonal up
            if (col_idx < cols - 3 and row_idx > 2) {
                if (lines.items[row_idx][col_idx] == 'X' and lines.items[row_idx - 1][col_idx + 1] == 'M' and lines.items[row_idx - 2][col_idx + 2] == 'A' and lines.items[row_idx - 3][col_idx + 3] == 'S') xmas_count += 1
                else if (lines.items[row_idx][col_idx] == 'S' and lines.items[row_idx - 1][col_idx + 1] == 'A' and lines.items[row_idx - 2][col_idx + 2] == 'M' and lines.items[row_idx - 3][col_idx + 3] == 'X') xmas_count += 1; 
            }
        }
    }
    std.debug.print("{}\n", .{xmas_count});
}

pub fn partTwo(input: *Input) void {
    const lines = input.lines;
    const cols = lines.items[0].len;
    var x_mas: u32 = 0;
    for (1..lines.items.len - 1) |row_idx| {
        for (1..cols - 1) |col_idx| {
            if (isXmasBlock(lines, row_idx, col_idx)) x_mas += 1;
        }
    }
    std.debug.print("{}\n", .{x_mas});
}

pub fn isXmasBlock(lines: std.ArrayList([]u8), middle_r: usize, middle_c: usize) bool {
    const first_mas = lines.items[middle_r-1][middle_c-1] == 'M' and lines.items[middle_r][middle_c] == 'A' and lines.items[middle_r+1][middle_c+1] == 'S';
    const first_mas_2 = lines.items[middle_r-1][middle_c-1] == 'S' and lines.items[middle_r][middle_c] == 'A' and lines.items[middle_r+1][middle_c+1] == 'M';
    if (!first_mas and !first_mas_2) return false;
    const second_mas = lines.items[middle_r+1][middle_c-1] == 'M' and lines.items[middle_r][middle_c] == 'A' and lines.items[middle_r-1][middle_c+1] == 'S';
    const second_mas_2 = lines.items[middle_r+1][middle_c-1] == 'S' and lines.items[middle_r][middle_c] == 'A' and lines.items[middle_r-1][middle_c+1] == 'M';
    return second_mas or second_mas_2;
}