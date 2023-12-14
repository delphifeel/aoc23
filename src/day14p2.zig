const std = @import("std");
const mem = std.mem;
const Allocator = std.mem.Allocator;
const debug = std.debug;
const aoc_input = @import("aoc_input.zig");
const string_view = aoc_input.string_view;
const read_aoc_input = aoc_input.read_aoc_input;

fn doMoves(last_rock_pos: []?usize, data: [][]u8, dir: []i32) void {
    // clear
    for (last_rock_pos) |*item| {
        item.* = null;
    }

    var cols_count = data[0].len;
    var rows_count = data.len;

    if (dir[0] == 0) {
        // rows to cols
        for (0..rows_count) |i| {
            var row: usize = undefined;
            if (dir[1] == 1) {
                row = i;
            } else {
                row = rows_count - i - 1;
            }

            var row_number = rows_count - row;
            for (0..cols_count) |col| {
                var c = data[row][col];
                if (c == 'O') {
                    if (last_rock_pos[col]) |row_v| {
                        var row_v_i: i32 = @intCast(row_v);
                        last_rock_pos[col] = @intCast(row_v_i - dir[1]);
                    } else {
                        if (dir[1] == 1) {
                            last_rock_pos[col] = rows_count;
                        } else {
                            last_rock_pos[col] = 1;
                        }
                    }

                    var new_row = last_rock_pos[col] orelse unreachable;
                    data[row][col] = '.';
                    data[rows_count - new_row][col] = 'O';
                    continue;
                }
                if (c == '#') {
                    last_rock_pos[col] = row_number;
                    continue;
                }
            }
        }
    } else {
        // (1, 0)
        // cols to rows
        for (0..cols_count) |j| {
            var col: usize = undefined;
            if (dir[0] == 1) {
                col = j;
            } else {
                col = cols_count - j - 1;
            }

            var col_number = col + 1;
            for (0..rows_count) |row| {
                var c = data[row][col];
                if (c == 'O') {
                    if (last_rock_pos[row]) |col_v| {
                        var col_v_i: i32 = @intCast(col_v);
                        last_rock_pos[row] = @intCast(col_v_i + dir[0]);
                    } else {
                        if (dir[0] == 1) {
                            last_rock_pos[row] = 1;
                        } else {
                            last_rock_pos[row] = cols_count;
                        }
                    }

                    var new_col = last_rock_pos[row] orelse unreachable;
                    data[row][col] = '.';
                    data[row][new_col - 1] = 'O';
                    continue;
                }
                if (c == '#') {
                    last_rock_pos[row] = col_number;
                    continue;
                }
            }
        }
    }
}

fn doFullCircle(last_rock_pos: []?usize, lines: [][]u8, dir: []i32) void {
    var count: u32 = 4;
    while (count > 0) {
        doMoves(last_rock_pos, lines, dir);

        if ((dir[1] == 1) and (dir[0] == 0)) {
            dir[0] = 1;
            dir[1] = 0;
        } else if ((dir[0] == 1) and (dir[1] == 0)) {
            dir[0] = 0;
            dir[1] = -1;
        } else if ((dir[0] == 0) and (dir[1] == -1)) {
            dir[0] = -1;
            dir[1] = 0;
        } else if ((dir[0] == -1) and (dir[1] == 0)) {
            dir[0] = 0;
            dir[1] = 1;
        }

        count -= 1;
    }
}

fn fillLines(to: [][]u8, from: []const []const u8) void {
    var cols_count = from[0].len;
    var rows_count = from.len;

    for (0..rows_count) |row| {
        for (0..cols_count) |col| {
            to[row][col] = from[row][col];
        }
    }
}

fn linesChanged(orig: []const []const u8, curr: []const []const u8) bool {
    debug.print("compare: \n", .{});

    for (orig) |l| {
        debug.print("{s}\n", .{l});
    }

    debug.print("to: \n", .{});

    for (curr) |l| {
        debug.print("{s}\n", .{l});
    }

    var cols_count = curr[0].len;
    var rows_count = curr.len;

    for (0..rows_count) |row| {
        for (0..cols_count) |col| {
            if (orig[row][col] != curr[row][col]) {
                return true;
            }
        }
    }

    return false;
}

fn calc(allocator: Allocator, lines: [][]u8) usize {
    var cols_count = lines[0].len;
    var rows_count = lines.len;

    var lines_orig = allocator.alloc([]u8, rows_count) catch unreachable;
    for (0..rows_count) |row| {
        lines_orig[row] = allocator.alloc(u8, cols_count) catch unreachable;
    }
    defer {
        for (lines_orig) |line| {
            allocator.free(line);
        }
        allocator.free(lines_orig);
    }

    // init last rock info
    var last_rock_pos = allocator.alloc(?usize, @max(cols_count, rows_count)) catch unreachable;
    defer allocator.free(last_rock_pos);
    var dir: [2]i32 = .{ 0, 1 };
    var count: u64 = 1000000;
    var iter: u64 = 0;
    while (count > 0) {
        //debug.print("ITER #{}\n", .{iter});
        doFullCircle(last_rock_pos, lines, &dir);

        // calc sum
        var sum: usize = 0;
        for (lines, 0..) |line, i| {
            var row = rows_count - i;
            for (line) |c| {
                if (c == 'O') {
                    sum += row;
                }
            }
        }
        debug.print("sum: {}\n", .{sum});

        if (iter == 0) {
            fillLines(lines_orig, lines);
        }
        if (iter % 27 == 0) {
            if (!linesChanged(lines_orig, lines)) {
                if (iter > 0) {
                    break;
                }
            }
            fillLines(lines_orig, lines);
        }
        iter += 1;
        count -= 1;
    }

    // calc sum
    var sum: usize = 0;
    for (lines, 0..) |line, i| {
        var row = rows_count - i;
        for (line) |c| {
            if (c == 'O') {
                sum += row;
                continue;
            }
        }
    }

    return sum;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    debug.assert(gpa.detectLeaks() == false);
    var allocator = gpa.allocator();

    var aocInput = try read_aoc_input(allocator, "input_d14.txt");
    defer aocInput.deinit();
    var sum = calc(allocator, aocInput.list.items);
    debug.print("REAL sum: {}\n", .{sum});
}

test "simple test" {
    var allocator = std.testing.allocator;

    var aocInput = try read_aoc_input(allocator, "d14test.txt");
    defer aocInput.deinit();

    var sum = calc(allocator, aocInput.list.items);
    _ = sum;
    //debug.assert(sum == 64);
}
