const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const input = "input.txt";

const stdout_file = std.io.getStdOut().writer();
var bw = std.io.bufferedWriter(stdout_file);
const stdout = bw.writer();

pub fn main() !u8 {
    return @intFromBool(!(try part_one() == 0 and try part_two() == 0));
}

pub fn part_one() !u8 {
    const stats = try std.fs.cwd().statFile(input);
    const contents = try allocator.alloc(u8, stats.size);
    defer allocator.free(contents);

    const file = try std.fs.cwd().openFile(input, .{});
    defer file.close();

    const file_reader = file.reader();

    var list = std.ArrayList([2]u64).init(allocator);
    defer list.deinit();

    while (try file_reader.readUntilDelimiterOrEofAlloc(allocator, '\n', 8192)) |line| {
        var split = std.mem.splitSequence(u8, line, "   ");
        try list.append(.{
            try std.fmt.parseInt(u64, split.next().?, 10),
            try std.fmt.parseInt(u64, split.next().?, 10),
        });
    }

    for (0..list.items.len) |x| {
        var smallest = [2]u64{ std.math.maxInt(u64), std.math.maxInt(u64) };
        var indexes: [2]usize = undefined;

        for (x..list.items.len) |y| {
            if (list.items[y][0] < smallest[0]) {
                smallest[0] = list.items[y][0];
                indexes[0] = y;
            }
            if (list.items[y][1] < smallest[1]) {
                smallest[1] = list.items[y][1];
                indexes[1] = y;
            }
        }

        const tmp: [2]u64 = list.items[x];

        list.items[x][0] = smallest[0];
        list.items[x][1] = smallest[1];

        list.items[indexes[0]][0] = tmp[0];
        list.items[indexes[1]][1] = tmp[1];
    }

    var distance: usize = 0;

    for (list.items) |i| {
        if (i[0] > i[1]) {
            distance += i[0] - i[1];
        } else {
            distance += i[1] - i[0];
        }
    }

    try stdout.print("part_one: {d}\n", .{distance});
    try bw.flush();

    return 0;
}

pub fn part_two() !u8 {
    const stats = try std.fs.cwd().statFile(input);
    const contents = try allocator.alloc(u8, stats.size);
    defer allocator.free(contents);

    const file = try std.fs.cwd().openFile(input, .{});
    defer file.close();

    const file_reader = file.reader();

    var hashmap = std.AutoHashMap(u64, u64).init(allocator);
    defer hashmap.deinit();

    var list = std.ArrayList(u64).init(allocator);
    defer list.deinit();

    while (try file_reader.readUntilDelimiterOrEofAlloc(allocator, '\n', 8192)) |line| {
        var split = std.mem.splitSequence(u8, line, "   ");

        const one = try std.fmt.parseInt(u64, split.next().?, 10);
        const two = try std.fmt.parseInt(u64, split.next().?, 10);

        if (hashmap.get(two)) |i| {
            try hashmap.put(two, i + 1);
        } else {
            try hashmap.put(two, 1);
        }

        try list.append(one);
    }

    var distance: usize = 0;

    for (list.items) |i| {
        if (hashmap.get(i)) |x| {
            distance += i * x;
        }
    }

    try stdout.print("part_two: {d}\n", .{distance});
    try bw.flush();

    return 0;
}
