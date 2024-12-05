const std = @import("std");

const Tuple = struct {left: u32, right: u32};
const PageOrdering = std.AutoHashMap(Tuple, void);
const Update = std.ArrayList(u32);
const Input = struct {
    page_ordering: PageOrdering,
    updates: std.ArrayList(Update),
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    var input = try parseInput(allocator);
    partOne(&input);
    partTwo(&input);
}

pub fn parseInput(allocator: std.mem.Allocator) !Input {
    const input = try std.fs.cwd().openFile("Day05/input.txt", .{});
    defer input.close();
    var input_reader = std.io.bufferedReader(input.reader());
    var input_stream = input_reader.reader();
    var buffer: [1024]u8 = undefined;
    var hash_set = PageOrdering.init(allocator);
    var ordering = true;
    var updates = std.ArrayList(Update).init(allocator);
    while (try input_stream.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        if (line.len == 0) {
            ordering = false;
            continue;
        }
        if (ordering) {
            var splits = std.mem.splitScalar(u8, line, '|');
            const left = splits.next() orelse return error.InputFormatError;
            const left_num = try std.fmt.parseInt(u32, left, 10);
            const right = splits.next() orelse return error.InputFormatError;
            const right_num = try std.fmt.parseInt(u32, right, 10);
            hash_set.put(Tuple {.left = left_num, .right = right_num}, {}) catch unreachable;
        } else {
            var update = Update.init(allocator);
            var splits = std.mem.splitScalar(u8, line, ',');
            while (splits.next()) |split| {
                const num = try std.fmt.parseInt(u32, split, 10);
                update.append(num) catch unreachable;
            }
            updates.append(update) catch unreachable;
        }
    }
    return Input {.page_ordering = hash_set, .updates = updates};
}

pub fn partOne(input: *Input) void {
    var sum: u32 = 0;
    outer: for (input.updates.items) |update| {
        for (0..update.items.len) |i| {
            for (i+1..update.items.len) |j| {
                if (input.page_ordering.contains(Tuple {.left = update.items[j], .right = update.items[i]})) continue :outer;
            }
        }
        sum += update.items[update.items.len / 2];
    }
    std.debug.print("{}\n", .{sum});
}

pub fn partTwo(input: *Input) void {
    var sum: u32 = 0;
    for (input.updates.items) |update| {
        var looped = false;
        while (true) {
            var cont = false;
            for (0..update.items.len) |i| {
                for (i+1..update.items.len) |j| {
                    if (input.page_ordering.contains(Tuple {.left = update.items[j], .right = update.items[i]})) {
                        std.mem.swap(u32, &update.items[i], &update.items[j]);
                        looped = true;
                        cont = true;
                    }
                }
            }
            if (cont) continue;
            break;
        }
        if (looped) sum += update.items[update.items.len / 2];
    }
    std.debug.print("{}\n", .{sum});
}