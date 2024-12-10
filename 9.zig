const std = @import("std");

const stdout_file = std.io.getStdOut().writer();
var bw = std.io.bufferedWriter(stdout_file);
const stdout = bw.writer();

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const input = "input.txt";

pub fn main() !u8 {
    return @intFromBool(!(try part_one() == 0 and try part_two() == 0));
}

fn part_one() !u8 {
    const file = try std.fs.cwd().openFile(input, .{});
    const stats = try std.fs.cwd().statFile(input);

    const buf = try allocator.alloc(u8, stats.size);
    defer allocator.free(buf);

    _ = try file.reader().readAll(buf);

    var fs = std.ArrayList(?usize).init(allocator);
    defer fs.deinit();

    var add_file = true;
    var index: usize = 0;

    for (buf) |i| {
        if (i == '\n') break;
        const number = i - 48;
        if (add_file) {
            for (0..number) |_| {
                try fs.append(index);
            }
            index += 1;
        } else {
            for (0..number) |_| {
                try fs.append(null);
            }
        }
        add_file = !add_file;
    }

    var null_before_number = true;
    while (null_before_number) {
        var last: usize = 0;
        var first_null: usize = 0;

        for (0..fs.items.len) |i| {
            if (first_null == 0 and fs.items[i] == null) {
                first_null = i;
            }
            if (fs.items[i]) |_| {
                last = i;
            }
        }
        null_before_number = first_null < last;
        if (null_before_number) {
            fs.items[first_null] = fs.items[last];
            fs.items[last] = null;
        }
    }

    var total: usize = 0;

    for (0..fs.items.len) |i| {
        if (fs.items[i]) |num| {
            total += i * num;
        }
    }

    try stdout.print("part one: {d}\n", .{total});
    try bw.flush();

    return 0;
}

fn part_two() !u8 {
    const file = try std.fs.cwd().openFile(input, .{});
    const stats = try std.fs.cwd().statFile(input);

    const buf = try allocator.alloc(u8, stats.size);
    defer allocator.free(buf);

    _ = try file.reader().readAll(buf);

    var fs = std.ArrayList(?usize).init(allocator);
    defer fs.deinit();

    var add_file = true;
    var index: usize = 0;

    for (buf) |i| {
        if (i == '\n') break;
        const number = i - 48;
        if (add_file) {
            for (0..number) |_| {
                try fs.append(index);
            }
            index += 1;
        } else {
            for (0..number) |_| {
                try fs.append(null);
            }
        }
        add_file = !add_file;
    }

    for (0..index) |y| {
        const looks_for = index - y - 1;

        var last_size: usize = 0;
        var last_one_index: usize = 0;

        for (0..fs.items.len) |i| {
            if (fs.items[i] == looks_for) {
                last_size += 1;
                last_one_index = i;
            }
        }

        var current_size: usize = 0;

        for (0..last_one_index) |i| {
            if (current_size == last_size) {
                std.mem.copyForwards(?usize, fs.items[i - current_size .. i], fs.items[last_one_index - current_size + 1 .. last_one_index + 1]);
                for (last_one_index - current_size + 1..last_one_index + 1) |x| {
                    fs.items[x] = null;
                }
                break;
            }
            if (fs.items[i] == null) {
                current_size += 1;
            } else {
                current_size = 0;
            }
        }
    }

    var total: usize = 0;

    for (0..fs.items.len) |i| {
        if (fs.items[i]) |num| {
            total += i * num;
        }
    }

    try stdout.print("part two: {d}\n", .{total});
    try bw.flush();
    return 0;
}
