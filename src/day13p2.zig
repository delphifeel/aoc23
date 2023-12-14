const std = @import("std");
const mem = std.mem;
const Allocator = std.mem.Allocator;
const debug = std.debug;
const aoc_input = @import("aoc_input.zig");
const string_view = aoc_input.string_view;
const read_aoc_input = aoc_input.read_aoc_input;

fn findRowsWith1Diff(
    group_lines: []const string_view,
    row1: usize,
    row2: usize,
) ?usize {
    var diff: ?usize = null;
    for (0..group_lines[0].len) |col| {
        if (group_lines[row1][col] != group_lines[row2][col]) {
            if (diff != null) {
                return null;
            }
            diff = col;
        }
    }
    return diff;
}

fn findColsWith1Diff(
    group_lines: []const string_view,
    col1: usize,
    col2: usize,
) ?usize {
    var diff: ?usize = null;
    for (0..group_lines.len) |row| {
        if (group_lines[row][col1] != group_lines[row][col2]) {
            if (diff != null) {
                return null;
            }
            diff = row;
        }
    }
    return diff;
}

fn findDiff(
    group_lines: []const string_view,
    from_row: usize,
    till_row: usize,
    from_col: usize,
    till_col: usize,
) usize {
    _ = till_col;
    _ = from_col;
    _ = till_row;
    _ = from_row;
    _ = group_lines;
    //debug.print("row: {}:{}\ncol: {}:{}\n", .{ from_row, till_row, from_col, till_col });
    return 0;
}

fn compare_rows(group_lines: []const string_view, top: usize, low: usize) usize {
    var prev = group_lines[top];
    var curr = group_lines[low];
    if (!mem.eql(u8, prev, curr)) {
        return 0;
    }

    var lowest = group_lines.len - 1;
    var new_top = top;
    var new_low = low;
    // compare going top and bottom
    while (true) {
        if (new_top == 0) {
            new_top = new_low + 1;
            new_low = lowest + 1;
            break;
        }
        if (new_low == lowest) {
            new_low = new_top;
            new_top = 0;
            break;
        }

        new_top -= 1;
        new_low += 1;
        for (0..group_lines[0].len) |col| {
            if (group_lines[new_top][col] != group_lines[new_low][col]) {
                return 0;
            }
        }
    }

    //debug.print("top: {}, low: {}\n", .{ new_top, new_low });
    return (top + 1) * 100;
}

fn compare_cols(group_lines: []const string_view, left: usize, right: usize) usize {
    for (0..group_lines.len) |row| {
        if (group_lines[row][left] != group_lines[row][right]) {
            return 0;
        }
    }

    var last = group_lines[0].len - 1;
    var new_left = left;
    var new_right = right;
    while (true) {
        if (new_left == 0) {
            new_left = new_right + 1;
            new_right = last + 1;
            break;
        }
        if (new_right == last) {
            new_right = new_left;
            new_left = 0;
            break;
        }

        new_left -= 1;
        new_right += 1;

        for (0..group_lines.len) |row| {
            if (group_lines[row][new_left] != group_lines[row][new_right]) {
                return 0;
            }
        }
    }

    //debug.print("left: {}, right: {}\n", .{ new_left, new_right });

    return left + 1;
}

// Maybe use matrix instead of list of list
fn calcGroup(allocator: Allocator, group_lines: []string_view) usize {
    _ = allocator;
    // find for rows reflection
    for (1..group_lines.len) |i| {
        var v = compare_rows(group_lines, i - 1, i);
        if (v > 0) {
            return v;
        }
    }

    // find for cols reflection
    for (1..group_lines[0].len) |col| {
        var v = compare_cols(group_lines, col - 1, col);
        if (v > 0) {
            return v;
        }
    }
    return 0;
}

fn testGroup(allocator: Allocator, group_lines: [][]u8) usize {
    // calc original
    var orig_sum = calcGroup(allocator, group_lines);
    debug.print("---------------------\n", .{});
    debug.print("orig sum: {}\n", .{orig_sum});

    // testing all row possibilities
    for (0..group_lines.len) |i| {
        for ((i + 1)..group_lines.len) |j| {
            var col = findRowsWith1Diff(group_lines, i, j) orelse continue;
            // first change both rows to .
            var prev_i = group_lines[i][col];
            var prev_j = group_lines[j][col];

            debug.print("row {} <-> {}, col: {}\n", .{ i, j, col });

            group_lines[i][col] = '.';
            group_lines[j][col] = '.';
            var sum = calcGroup(allocator, group_lines);
            group_lines[i][col] = prev_i;
            group_lines[j][col] = prev_j;
            debug.print("sum: {}\n", .{sum});
            if ((sum > 0) and (sum != orig_sum)) {
                return sum;
            }

            group_lines[i][col] = '#';
            group_lines[j][col] = '#';
            sum = calcGroup(allocator, group_lines);
            group_lines[i][col] = prev_i;
            group_lines[j][col] = prev_j;
            debug.print("sum: {}\n", .{sum});
            if ((sum > 0) and (sum != orig_sum)) {
                return sum;
            }
        }
    }

    // testing all cols possibilities
    for (0..group_lines[0].len) |i| {
        for ((i + 1)..group_lines[0].len) |j| {
            var row = findColsWith1Diff(group_lines, i, j) orelse continue;
            // first change both rows to .
            var prev_i = group_lines[row][i];
            var prev_j = group_lines[row][j];

            debug.print("col {} <-> {}, row: {}\n", .{ i, j, row });

            group_lines[row][i] = '.';
            group_lines[row][j] = '.';
            var sum = calcGroup(allocator, group_lines);
            group_lines[row][i] = prev_i;
            group_lines[row][j] = prev_j;
            debug.print("sum: {}\n", .{sum});
            if ((sum > 0) and (sum != orig_sum)) {
                return sum;
            }

            group_lines[row][i] = '#';
            group_lines[row][j] = '#';
            sum = calcGroup(allocator, group_lines);
            group_lines[row][i] = prev_i;
            group_lines[row][j] = prev_j;
            debug.print("sum: {}\n", .{sum});
            if ((sum > 0) and (sum != orig_sum)) {
                return sum;
            }
        }
    }
    return orig_sum;
}

fn calc(allocator: Allocator, lines: [][]u8) usize {
    var sum: usize = 0;
    var start_i: usize = 0;
    for (lines, 0..) |line, i| {
        if (line.len == 0) {
            sum += testGroup(allocator, lines[start_i..i]);
            start_i = i + 1;
        }
    }
    if (start_i < lines.len) {
        sum += testGroup(allocator, lines[start_i..]);
    }
    return sum;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    debug.assert(gpa.detectLeaks() == false);
    var allocator = gpa.allocator();

    var aocInput = try read_aoc_input(allocator, "input_d13.txt");
    defer aocInput.deinit();
    var sum = calc(allocator, aocInput.list.items);
    debug.print("sum: {}\n", .{sum});
}

test "simple test" {
    var allocator = std.testing.allocator;

    var aocInput = try read_aoc_input(allocator, "d13test.txt");
    defer aocInput.deinit();

    var sum = calc(allocator, aocInput.list.items);
    debug.assert(sum == 400);
}
