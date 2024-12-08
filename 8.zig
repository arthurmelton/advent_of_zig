const std = @import("std");

const stdout_file = std.io.getStdOut().writer();
var bw = std.io.bufferedWriter(stdout_file);
const stdout = bw.writer();

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

const input = "input.txt";

const width = 50;
const height = 50;

pub fn main() !u8 {
    return @intFromBool(!(try part_one() == 0 and try part_two() == 0));
}

fn part_one() !u8 {
    const file = (try std.fs.cwd().openFile(input, .{})).reader();

    var buf: [(width + 1) * height]u8 = undefined;
    _ = try file.read(&buf);

    var antinodes: [(width + 1) * height]bool = undefined;
    @memset(&antinodes, false);

    var nodes: [std.math.maxInt(u8)]std.ArrayList(@Vector(2, isize)) = undefined;
    @memset(&nodes, std.ArrayList(@Vector(2, isize)).init(allocator));
    defer {
        for (nodes) |i| {
            i.deinit();
        }
    }

    for (0..height) |y| {
        for (0..width) |x| {
            if (buf[y * (width + 1) + x] != '.') {
                try nodes[buf[y * (width + 1) + x]].append(.{ @intCast(x), @intCast(y) });
            }
        }
    }

    for (nodes) |i| {
        for (i.items) |x| {
            for (i.items) |y| {
                if (x[0] != y[0] or x[1] != y[1]) {
                    const first = @Vector(2, isize){ x[0] + (x[0] - y[0]), x[1] + (x[1] - y[1]) };
                    const second = @Vector(2, isize){ y[0] - (x[0] - y[0]), y[1] - (x[1] - y[1]) };
                    if (first[0] >= 0 and first[0] < width and first[1] >= 0 and first[1] < height) {
                        antinodes[@intCast(first[1] * (width + 1) + first[0])] = true;
                    }
                    if (second[0] >= 0 and second[0] < width and second[1] >= 0 and second[1] < height) {
                        antinodes[@intCast(second[1] * (width + 1) + second[0])] = true;
                    }
                }
            }
        }
    }

    try stdout.print("part one: {d}\n", .{std.mem.count(bool, &antinodes, &[_]bool{true})});
    try bw.flush();
    return 0;
}

fn part_two() !u8 {
    const file = (try std.fs.cwd().openFile(input, .{})).reader();

    var buf: [(width + 1) * height]u8 = undefined;
    _ = try file.read(&buf);

    var antinodes: [(width + 1) * height]bool = undefined;
    @memset(&antinodes, false);

    var nodes: [std.math.maxInt(u8)]std.ArrayList(@Vector(2, isize)) = undefined;
    @memset(&nodes, std.ArrayList(@Vector(2, isize)).init(allocator));
    defer {
        for (nodes) |i| {
            i.deinit();
        }
    }

    for (0..height) |y| {
        for (0..width) |x| {
            if (buf[y * (width + 1) + x] != '.') {
                try nodes[buf[y * (width + 1) + x]].append(.{ @intCast(x), @intCast(y) });
            }
        }
    }

    for (nodes) |i| {
        for (i.items) |x| {
            for (i.items) |y| {
                if (x[0] != y[0] or x[1] != y[1]) {
                    antinodes[@intCast(x[1] * (width + 1) + x[0])] = true;

                    var first = @Vector(2, isize){ x[0] + (x[0] - y[0]), x[1] + (x[1] - y[1]) };
                    var second = @Vector(2, isize){ y[0] - (x[0] - y[0]), y[1] - (x[1] - y[1]) };
                    while (first[0] >= 0 and first[0] < width and first[1] >= 0 and first[1] < height) {
                        antinodes[@intCast(first[1] * (width + 1) + first[0])] = true;
                        first[0] += x[0] - y[0];
                        first[1] += x[1] - y[1];
                    }
                    while (second[0] >= 0 and second[0] < width and second[1] >= 0 and second[1] < height) {
                        antinodes[@intCast(second[1] * (width + 1) + second[0])] = true;
                        second[0] -= x[0] - y[0];
                        second[1] -= x[1] - y[1];
                    }
                }
            }
        }
    }

    try stdout.print("part two: {d}\n", .{std.mem.count(bool, &antinodes, &[_]bool{true})});
    try bw.flush();
    return 0;
}
