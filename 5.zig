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
    const stats = try std.fs.cwd().statFile(input);

    const data = try allocator.alloc(u8, stats.size);
    defer allocator.free(data);

    _ = try std.fs.cwd().readFile(input, data);

    var sections = std.mem.splitSequence(u8, data, "\n\n");

    var must_be_before = std.AutoArrayHashMap(usize, std.ArrayList(usize)).init(allocator);
    defer {
        var it = must_be_before.iterator();
        while (it.next()) |i| {
            i.value_ptr.deinit();
        }
        must_be_before.deinit();
    }

    const first = sections.next() orelse return 1;
    const second = sections.next() orelse return 1;

    var total: usize = 0;

    var first_lines = std.mem.splitScalar(u8, first, '\n');
    while (first_lines.next()) |line| {
        var numbers = std.mem.splitScalar(u8, line, '|');
        const first_number = try std.fmt.parseInt(usize, numbers.next() orelse return 1, 10);
        const second_number = try std.fmt.parseInt(usize, numbers.next() orelse return 1, 10);

        if (must_be_before.getPtr(second_number)) |array| {
            try array.append(first_number);
        } else {
            var array = std.ArrayList(usize).init(allocator);
            try array.append(first_number);
            try must_be_before.put(second_number, array);
        }
    }

    var second_lines = std.mem.splitScalar(u8, second, '\n');
    while (second_lines.next()) |line| {
        if (line.len == 0) continue;

        var numbers_s = std.mem.splitScalar(u8, line, ',');
        var numbers = std.ArrayList(usize).init(allocator);
        defer numbers.deinit();

        while (numbers_s.next()) |number| {
            try numbers.append(try std.fmt.parseInt(usize, number, 10));
        }

        var safe = true;
        checks: for (0..numbers.items.len) |i| {
            if (must_be_before.get(numbers.items[i])) |numbers_to_check| {
                for (numbers_to_check.items) |number| {
                    if (std.mem.indexOf(usize, numbers.items, &[1]usize{number}) orelse 0 > i) {
                        safe = false;
                        break :checks;
                    }
                }
            }
        }

        if (safe) {
            const middle = numbers.items[numbers.items.len / 2];
            total += middle;
        }
    }

    try stdout.print("part one: {d}\n", .{total});
    try bw.flush();

    return 0;
}

fn part_two() !u8 {
    const stats = try std.fs.cwd().statFile(input);

    const data = try allocator.alloc(u8, stats.size);
    defer allocator.free(data);

    _ = try std.fs.cwd().readFile(input, data);

    var sections = std.mem.splitSequence(u8, data, "\n\n");

    var must_be_before = std.AutoArrayHashMap(usize, std.ArrayList(usize)).init(allocator);
    defer {
        var it = must_be_before.iterator();
        while (it.next()) |i| {
            i.value_ptr.deinit();
        }
        must_be_before.deinit();
    }

    const first = sections.next() orelse return 1;
    const second = sections.next() orelse return 1;

    var total: usize = 0;

    var first_lines = std.mem.splitScalar(u8, first, '\n');
    while (first_lines.next()) |line| {
        var numbers = std.mem.splitScalar(u8, line, '|');
        const first_number = try std.fmt.parseInt(usize, numbers.next() orelse return 1, 10);
        const second_number = try std.fmt.parseInt(usize, numbers.next() orelse return 1, 10);

        if (must_be_before.getPtr(second_number)) |array| {
            try array.append(first_number);
        } else {
            var array = std.ArrayList(usize).init(allocator);
            try array.append(first_number);
            try must_be_before.put(second_number, array);
        }
    }

    var second_lines = std.mem.splitScalar(u8, second, '\n');
    while (second_lines.next()) |line| {
        if (line.len == 0) continue;

        var numbers_s = std.mem.splitScalar(u8, line, ',');
        var numbers = std.ArrayList(usize).init(allocator);
        defer numbers.deinit();

        while (numbers_s.next()) |number| {
            try numbers.append(try std.fmt.parseInt(usize, number, 10));
        }

        var safe = true;
        checks: for (0..numbers.items.len) |i| {
            if (must_be_before.get(numbers.items[i])) |numbers_to_check| {
                for (numbers_to_check.items) |number| {
                    if (std.mem.indexOf(usize, numbers.items, &[1]usize{number}) orelse 0 > i) {
                        safe = false;
                        break :checks;
                    }
                }
            }
        }

        if (!safe) {
            var done: usize = 0;
            var new_ordering = try allocator.alloc(usize, numbers.items.len);
            @memset(new_ordering, 0);

            while (done != numbers.items.len) {
                for (0..numbers.items.len) |i| {
                    if (must_be_before.get(numbers.items[i])) |numbers_to_check| {
                        var can_add = true;
                        for (numbers_to_check.items) |number| {
                            if (std.mem.containsAtLeast(usize, numbers.items, 1, &[1]usize{number}) and !std.mem.containsAtLeast(usize, new_ordering, 1, &[1]usize{number})) {
                                can_add = false;
                            }
                        }
                        if (can_add and !std.mem.containsAtLeast(usize, new_ordering, 1, &[1]usize{numbers.items[i]})) {
                            new_ordering[done] = numbers.items[i];
                            done += 1;
                        }
                    } else if (!std.mem.containsAtLeast(usize, new_ordering, 1, &[1]usize{numbers.items[i]})) {
                        new_ordering[done] = numbers.items[i];
                        done += 1;
                    }
                }
            }

            const middle = new_ordering[new_ordering.len / 2];
            total += middle;
        }
    }

    try stdout.print("part two: {d}\n", .{total});
    try bw.flush();

    return 0;
}
