const std = @import("std");

const stdout_file = std.io.getStdOut().writer();
var bw = std.io.bufferedWriter(stdout_file);
const stdout = bw.writer();

const input = "input.txt";

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn main() !u8 {
    return @intFromBool(!(try part_one() == 0 and try part_two() == 0));
}

fn part_one() !u8 {
    const file = (try std.fs.cwd().openFile(input, .{})).reader();

    var safe_count: usize = 0;

    while (try file.readUntilDelimiterOrEofAlloc(allocator, '\n', 8192)) |line| {
        var safe = true;

        var last: i64 = 0;
        var inc = true;

        var is_first = true;
        var is_second = true;

        var numbers = std.mem.splitScalar(u8, line, ' ');
        while (numbers.next()) |num| {
            if (safe) {
                const number = try std.fmt.parseInt(@TypeOf(last), num, 10);
                if (is_first) {
                    last = number;
                    is_first = false;
                } else {
                    if (is_second) {
                        is_second = false;
                        inc = number > last;
                    }
                    safe = (inc and last + 1 <= number and last + 3 >= number) or
                        (!inc and last - 1 >= number and last - 3 <= number);
                    last = number;
                }
            }
        }

        if (safe) safe_count += 1;
    }

    try stdout.print("part one: {d}\n", .{safe_count});
    try bw.flush();

    return 0;
}

fn part_two() !u8 {
    const file = (try std.fs.cwd().openFile(input, .{})).reader();

    var safe_count: usize = 0;

    while (try file.readUntilDelimiterOrEofAlloc(allocator, '\n', 8192)) |line| {
        var safe = false;

        var numbers_split = std.mem.splitScalar(u8, line, ' ');
        var numbers = std.ArrayList(i64).init(allocator);

        while (numbers_split.next()) |num| {
            try numbers.append(try std.fmt.parseInt(i64, num, 10));
        }

        if (part_two_is_valid(numbers.items)) {
            safe = true;
        }

        for (0..numbers.items.len) |i| {
            if (!safe) {
                var numbers_check = std.ArrayList(i64).init(allocator);
                for (0..i) |x| {
                    try numbers_check.append(numbers.items[x]);
                }
                for (i + 1..numbers.items.len) |x| {
                    try numbers_check.append(numbers.items[x]);
                }
                safe = part_two_is_valid(numbers_check.items);
            }
        }

        if (safe) safe_count += 1;
    }

    try stdout.print("part two: {d}\n", .{safe_count});
    try bw.flush();

    return 0;
}

fn part_two_is_valid(numbers: []i64) bool {
    var safe = true;

    var last: i64 = 0;
    var inc = true;

    var is_first = true;
    var is_second = true;

    for (numbers) |number| {
        if (safe) {
            if (is_first) {
                last = number;
                is_first = false;
            } else {
                if (is_second) {
                    is_second = false;
                    inc = number > last;
                }
                safe = (inc and last + 1 <= number and last + 3 >= number) or
                    (!inc and last - 1 >= number and last - 3 <= number);
                last = number;
            }
        }
    }
    return safe;
}
