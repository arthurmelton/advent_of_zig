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
    const file = (try std.fs.cwd().openFile(input, .{})).reader();

    var buf: [8196]u8 = undefined;

    var returns: usize = 0;

    while (try file.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var numbers = std.mem.splitScalar(u8, line, ' ');

        const total_s = numbers.next().?;
        const total = try std.fmt.parseInt(usize, total_s[0 .. total_s.len - 1], 10);

        var number_list = std.ArrayList(usize).init(allocator);

        while (numbers.next()) |number| {
            try number_list.append(try std.fmt.parseInt(usize, number, 10));
        }

        for (1..std.math.pow(usize, 2, number_list.items.len)) |x| {
            var current: usize = number_list.items[0];
            for (1..number_list.items.len) |y| {
                if (x & std.math.pow(usize, 2, y) > 0) {
                    current *= number_list.items[y];
                } else {
                    current += number_list.items[y];
                }
            }
            if (current == total) {
                returns += total;
                break;
            }
        }
    }

    try stdout.print("part one: {d}\n", .{returns});
    try bw.flush();
    return 0;
}

fn part_two() !u8 {
    const file = (try std.fs.cwd().openFile(input, .{})).reader();

    var buf: [8196]u8 = undefined;

    var returns: usize = 0;

    while (try file.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var numbers = std.mem.splitScalar(u8, line, ' ');

        const total_s = numbers.next().?;
        const total = try std.fmt.parseInt(usize, total_s[0 .. total_s.len - 1], 10);

        var number_list = std.ArrayList(usize).init(allocator);

        while (numbers.next()) |number| {
            try number_list.append(try std.fmt.parseInt(usize, number, 10));
        }

        main: for (3..std.math.pow(usize, 4, number_list.items.len)) |x| {
            var current: usize = number_list.items[0];
            for (1..number_list.items.len) |y| {
                const doing = (x >> @intCast(y * 2)) % 4;
                switch (doing) {
                    0 => current *= number_list.items[y],
                    1 => current += number_list.items[y],
                    2 => {
                        var length: usize = 1;
                        var doing_num = number_list.items[y];
                        while (doing_num > 9) {
                            length += 1;
                            doing_num /= 10;
                        }
                        current = std.math.pow(usize, 10, length) * current + number_list.items[y];
                    },
                    else => continue :main,
                }
            }
            if (current == total) {
                returns += total;
                break;
            }
        }
    }

    try stdout.print("part two: {d}\n", .{returns});
    try bw.flush();
    return 0;
}
