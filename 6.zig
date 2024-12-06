const std = @import("std");

const stdout_file = std.io.getStdOut().writer();
var bw = std.io.bufferedWriter(stdout_file);
const stdout = bw.writer();

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const input = "input.txt";

const width = 130;
const height = 130;

pub fn main() !u8 {
    return @intFromBool(!(try part_one() == 0 and try part_two() == 0));
}

fn part_one() !u8 {
    var buf: [(width + 1) * height]u8 = undefined;

    var have_gone: [(width + 1) * height]bool = undefined;
    @memset(&have_gone, false);

    _ = try std.fs.cwd().readFile(input, &buf);

    var pos: isize = @intCast(std.mem.indexOf(u8, &buf, "^") orelse return 1);
    have_gone[@intCast(pos)] = true;

    var moving: isize = -width - 1;

    while (pos >= 0 and pos < (width + 1) * height and buf[@intCast(pos)] != '\n') {
        if (buf[@intCast(pos)] != '#') {
            have_gone[@intCast(pos)] = true;
            pos += moving;
        } else {
            pos -= moving;
            moving = switch (moving) {
                -width - 1 => 1,
                1 => width + 1,
                width + 1 => -1,
                -1 => -width - 1,
                else => unreachable,
            };
        }
    }

    try stdout.print("part one: {d}\n", .{std.mem.count(bool, &have_gone, &[1]bool{true})});
    try bw.flush();
    return 0;
}

const part_two_direction = enum { up, right, down, left };

fn part_two() !u8 {
    var buf: [(width + 1) * height]u8 = undefined;

    var count: usize = 0;

    _ = try std.fs.cwd().readFile(input, &buf);

    const starting_pos: isize = @intCast(std.mem.indexOf(u8, &buf, "^") orelse return 1);

    for (0..height) |y| {
        for (0..width) |x| {
            var pos = starting_pos;

            var gone: [(width + 1) * height]u4 = undefined;
            @memset(&gone, 0);

            var moving: isize = -width - 1;
            var direction: part_two_direction = .up;

            while (pos >= 0 and pos < (width + 1) * height and buf[@intCast(pos)] != '\n') {
                if (gone[@intCast(pos)] & (std.math.shl(u4, 1, @intFromEnum(direction))) > 0) {
                    count += 1;
                    break;
                }
                if (buf[@intCast(pos)] != '#' and pos != (width + 1) * y + x) {
                    gone[@intCast(pos)] |= std.math.shl(u4, 1, @intFromEnum(direction));
                    pos += moving;
                } else {
                    pos -= moving;

                    direction = switch (direction) {
                        .up => .right,
                        .right => .down,
                        .down => .left,
                        .left => .up,
                    };

                    moving = switch (moving) {
                        -width - 1 => 1,
                        1 => width + 1,
                        width + 1 => -1,
                        -1 => -width - 1,
                        else => unreachable,
                    };
                }
            }
        }
    }

    try stdout.print("part two: {d}\n", .{count});
    try bw.flush();
    return 0;
}
