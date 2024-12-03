const std = @import("std");

const stdout_file = std.io.getStdOut().writer();
var bw = std.io.bufferedWriter(stdout_file);
const stdout = bw.writer();

const input = "input.txt";

pub fn main() !u8 {
    return @intFromBool(!(try part_one() == 0 and try part_two() == 0));
}

fn part_one() !u8 {
    const file = (try std.fs.cwd().openFile(input, .{})).reader();
    var buf: [12]u8 = undefined;

    var total: usize = 0;

    _ = try file.read(&buf);

    total += part_one_get_mul(buf);

    while (buf[0] != 0) {
        const x = file.readByte() catch 0;
        std.mem.copyForwards(u8, buf[0..11], buf[1..]);
        buf[11] = x;
        const update = part_one_get_mul(buf);
        total += update;
    }

    try stdout.print("part one: {d}\n", .{total});
    try bw.flush();

    return 0;
}

fn part_one_get_mul(string: [12]u8) u20 {
    if (std.mem.startsWith(u8, &string, "mul(")) {
        var inside = std.mem.splitScalar(u8, string[4..], ')');
        if (inside.next()) |inside_s| {
            if (inside.next()) |_| {
                var numbers = std.mem.splitScalar(u8, inside_s, ',');
                var first: u20 = undefined;

                if (numbers.next()) |number| {
                    if (number.len > 0 and number.len <= 3) {
                        first = std.fmt.parseInt(u20, number, 10) catch return 0;
                    } else return 0;
                } else return 0;

                if (numbers.next()) |number| {
                    if (number.len > 0 and number.len <= 3) {
                        const second = std.fmt.parseInt(u20, number, 10) catch return 0;
                        return first * second;
                    } else return 0;
                } else return 0;
            }
        }
    }

    return 0;
}

fn part_two() !u8 {
    const file = (try std.fs.cwd().openFile(input, .{})).reader();
    var buf: [12]u8 = undefined;

    var total: usize = 0;

    _ = try file.read(&buf);

    total += part_one_get_mul(buf);

    var can_mul = true;

    while (buf[0] != 0) {
        const x = file.readByte() catch 0;
        std.mem.copyForwards(u8, buf[0..11], buf[1..]);
        buf[11] = x;

        if (std.mem.startsWith(u8, &buf, "do()")) {
            can_mul = true;
        } else if (std.mem.startsWith(u8, &buf, "don't()")) {
            can_mul = false;
        }
        if (can_mul) {
            const update = part_one_get_mul(buf);
            total += update;
        }
    }

    try stdout.print("part two: {d}\n", .{total});
    try bw.flush();

    return 0;
}

fn part_two_get_mul(string: [12]u8) u20 {
    if (std.mem.startsWith(u8, &string, "mul(")) {
        var inside = std.mem.splitScalar(u8, string[4..], ')');
        if (inside.next()) |inside_s| {
            if (inside.next()) |_| {
                var numbers = std.mem.splitScalar(u8, inside_s, ',');
                var first: u20 = undefined;

                if (numbers.next()) |number| {
                    if (number.len > 0 and number.len <= 3) {
                        first = std.fmt.parseInt(u20, number, 10) catch return 0;
                    } else return 0;
                } else return 0;

                if (numbers.next()) |number| {
                    if (number.len > 0 and number.len <= 3) {
                        const second = std.fmt.parseInt(u20, number, 10) catch return 0;
                        return first * second;
                    } else return 0;
                } else return 0;
            }
        }
    }

    return 0;
}
