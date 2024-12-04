const std = @import("std");

const stdout_file = std.io.getStdOut().writer();
var bw = std.io.bufferedWriter(stdout_file);
const stdout = bw.writer();

const gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const input = "input.txt";

const width = 140;
const height = 140;

pub fn main() !u8 {
    return @intFromBool(!(try part_one() == 0 and try part_two() == 0));
}

fn part_one() !u8 {
    var data: [(width + 1) * height]u8 = undefined;

    _ = try std.fs.cwd().readFile(input, &data);

    var count: usize = 0;

    for (0..width) |x| {
        for (0..height) |y| {
            const current_pos: i64 = @intCast(y * (width + 1) + x);
            if (data[@intCast(current_pos)] == 'X') {
                for (0..8) |checks| {
                    var checking_pos = current_pos;
                    const adds: i64 = switch (checks) {
                        0 => 1, // right
                        1 => width + 1 + 1, // right down
                        2 => width + 1, // down
                        3 => width, // down left
                        4 => -1, // left
                        5 => -width - 1 - 1, // left up
                        6 => -width - 1, // up
                        7 => -width, // up right
                        else => unreachable,
                    };

                    for (0..3) |i| {
                        if (checking_pos + adds < 0 or checking_pos + adds >= (width + 1) * height) break;

                        checking_pos += adds;

                        const should_be: u8 = switch (i) {
                            0 => 'M',
                            1 => 'A',
                            2 => 'S',
                            else => unreachable,
                        };

                        if (data[@intCast(checking_pos)] != should_be) break;

                        if (i == 2) count += 1;
                    }
                }
            }
        }
    }

    try stdout.print("part one: {d}\n", .{count});
    try bw.flush();

    return 0;
}

fn part_two() !u8 {
    var data: [(width + 1) * height]u8 = undefined;

    _ = try std.fs.cwd().readFile(input, &data);

    var count: usize = 0;

    for (0..width) |x| {
        for (0..height) |y| {
            const current_pos: i64 = @intCast(y * (width + 1) + x);
            if (data[@intCast(current_pos)] == 'A') {
                if (current_pos - width - 2 >= 0 and current_pos + width + 1 + 1 < (width + 1) * height) {
                    for (0..4) |checks| {
                        const should_be = switch (checks) {
                            0 => "MMSS",
                            1 => "MSSM",
                            2 => "SSMM",
                            3 => "SMMS",
                            else => unreachable,
                        };

                        for (0..4) |i| {
                            const checking: i64 = switch (i) {
                                0 => -width - 2, // top left
                                1 => -width, // top right
                                2 => width + 2, // bottom right
                                3 => width, // bottom left
                                else => unreachable,
                            };

                            if (data[@intCast(current_pos + checking)] != should_be[i]) break;

                            if (i == 3) count += 1;
                        }
                    }
                }
            }
        }
    }

    try stdout.print("part two: {d}\n", .{count});
    try bw.flush();

    return 0;
}
