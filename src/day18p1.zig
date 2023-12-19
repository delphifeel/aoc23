const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;
const Allocator = std.mem.Allocator;
const debug = std.debug;
const aoc_input = @import("aoc_input.zig");
const string_view = aoc_input.string_view;
const read_aoc_input = aoc_input.read_aoc_input;

const Command = struct {
    dir: u8,
    value: isize,
};

fn dig(
    allocator: Allocator,
    start_x: usize,
    start_y: usize,
    x_size: usize,
    y_size: usize,
    commands: []const Command,
) []u8 {
    var pos_x = start_x;
    var pos_y = start_y;
    var matrix = allocator.alloc(u8, y_size * x_size) catch unreachable;
    @memset(matrix, '.');
    for (commands) |*c| {
        var dir = c.dir;
        var value: usize = @intCast(c.value);
        var curr_pos_x = pos_x;
        var curr_pos_y = pos_y;
        switch (dir) {
            'R' => {
                pos_x += value;
                while (curr_pos_x <= pos_x) {
                    matrix[curr_pos_y * x_size + curr_pos_x] = '#';
                    curr_pos_x += 1;
                }
            },
            'L' => {
                pos_x -= value;
                while (curr_pos_x >= pos_x) {
                    matrix[curr_pos_y * x_size + curr_pos_x] = '#';
                    if (curr_pos_x == 0) {
                        break;
                    }
                    curr_pos_x -= 1;
                }
            },
            'D' => {
                pos_y += value;
                while (curr_pos_y <= pos_y) {
                    matrix[curr_pos_y * x_size + curr_pos_x] = '#';
                    curr_pos_y += 1;
                }
            },
            'U' => {
                pos_y -= value;
                while (curr_pos_y >= pos_y) {
                    matrix[curr_pos_y * x_size + curr_pos_x] = '#';
                    if (curr_pos_y == 0) {
                        break;
                    }
                    curr_pos_y -= 1;
                }
            },
            else => unreachable,
        }
    }

    return matrix;
}

fn calcMatrix(matrix: []const u8, x_size: usize, y_size: usize) usize {
    var sum: usize = 0;

    for (0..y_size) |y| {
        var first: ?usize = null;
        var last: usize = 0;
        var inside = false;
        var on_it = false;

        for (0..x_size) |x| {
            var c = matrix[y * x_size + x];
            if (c == '#') {
                if (first == null) {
                    first = x;
                }
                last = x;
                if (inside and !on_it) {
                    on_it = true;
                }
                continue;
            }

            // .
            if (first != null) {
                if (!inside) {
                    inside = true;
                    continue;
                }
                if (inside and on_it) {
                    sum += last - first.? + 1;
                    first = null;
                    inside = false;
                    on_it = false;
                }
            }
        }
        if (first) |first_v| {
            sum += last - first_v + 1;
        }
    }

    return sum;
}

fn calc(allocator: Allocator, lines: [][]u8) usize {
    var commands = std.ArrayList(Command).initCapacity(allocator, lines.len) catch unreachable;
    defer commands.deinit();

    // parse perimiter and start pos
    var max_right_shift: isize = 0;
    var max_left_shift: isize = 0;
    var max_top_shift: isize = 0;
    var max_bot_shift: isize = 0;
    var x_shift: isize = 0;
    var y_shift: isize = 0;
    for (lines) |line| {
        var iter = mem.tokenizeScalar(u8, line, ' ');
        var dir = iter.next().?[0];
        var v = fmt.parseInt(isize, iter.next().?, 10) catch unreachable;
        commands.append(.{ .dir = dir, .value = v }) catch unreachable;

        switch (dir) {
            'R' => {
                x_shift += v;
                if (x_shift > max_right_shift) {
                    max_right_shift = x_shift;
                }
            },
            'L' => {
                x_shift -= v;
                if (x_shift < max_left_shift) {
                    max_left_shift = x_shift;
                }
            },
            'D' => {
                y_shift += v;
                if (y_shift > max_bot_shift) {
                    max_bot_shift = y_shift;
                }
            },
            'U' => {
                y_shift -= v;
                if (y_shift < max_top_shift) {
                    max_top_shift = y_shift;
                }
            },
            else => unreachable,
        }
    }

    max_right_shift += 1;
    max_left_shift = -max_left_shift;
    max_bot_shift += 1;
    max_top_shift = -max_top_shift;
    var x_start: usize = @intCast(max_left_shift);
    var y_start: usize = @intCast(max_top_shift);
    var x_size: usize = @intCast(max_left_shift + max_right_shift);
    var y_size: usize = @intCast(max_top_shift + max_bot_shift);
    //debug.print("x start: {}\ny start: {}\nx size: {}\ny size: {}\n", .{ x_start, y_start, x_size, y_size });

    var matrix = dig(
        allocator,
        x_start,
        y_start,
        x_size,
        y_size,
        commands.items,
    );
    defer allocator.free(matrix);

    for (0..y_size) |y| {
        for (0..x_size) |x| {
            debug.print("{c}", .{matrix[y * x_size + x]});
        }
        debug.print("\n", .{});
    }

    return calcMatrix(matrix, x_size, y_size);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    debug.assert(gpa.detectLeaks() == false);
    var allocator = gpa.allocator();

    var aocInput = try read_aoc_input(allocator, "input_d18.txt");
    defer aocInput.deinit();
    var sum = calc(allocator, aocInput.list.items);
    debug.print("REAL sum: {}\n", .{sum});
}

test "simple test" {
    var allocator = std.testing.allocator;

    var aocInput = try read_aoc_input(allocator, "d18test.txt");
    defer aocInput.deinit();

    var sum = calc(allocator, aocInput.list.items);
    debug.assert(sum == 62);
}
