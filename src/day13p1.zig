const std = @import("std");
const mem = std.mem;
const Allocator = std.mem.Allocator;
const debug = std.debug;
const aoc_input = @import("aoc_input.zig");
const string_view = aoc_input.string_view;
const read_aoc_input = aoc_input.read_aoc_input;

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
    while ((new_top != 0) and (new_low != lowest)) {
        new_top -= 1;
        new_low += 1;
        if (!mem.eql(u8, group_lines[new_top], group_lines[new_low])) {
            return 0;
        }
    }

    debug.print("top: {}, low: {}\n", .{ new_top, new_low });
    return (top + 1) * 100;
}

fn compare_cols(group_lines: []const string_view, left: usize, right: usize) usize {
    var same = true;
    for (0..group_lines.len) |row| {
        if (group_lines[row][left] != group_lines[row][right]) {
            same = false;
            break;
        }
    }
    if (!same) {
        return 0;
    }

    var last = group_lines[0].len - 1;
    var new_left = left;
    var new_right = right;
    while ((new_left != 0) and (new_right != last)) {
        new_left -= 1;
        new_right += 1;

        for (0..group_lines.len) |row| {
            if (group_lines[row][new_left] != group_lines[row][new_right]) {
                return 0;
            }
        }
    }

    debug.print("left: {}, right: {}\n", .{ new_left, new_right });

    return left + 1;
}

// Maybe use matrix instead of list of list
fn calcGroup(group_lines: []const string_view) usize {
    var sum: usize = 0;
    // find for rows reflection
    for (1..group_lines.len) |i| {
        sum += compare_rows(group_lines, i - 1, i);
    }

    // find for cols reflection
    for (1..group_lines[0].len) |col| {
        sum += compare_cols(group_lines, col - 1, col);
    }
    return sum;
}

fn calc(lines: []const string_view) usize {
    var sum: usize = 0;
    var start_i: usize = 0;
    for (lines, 0..) |line, i| {
        if (line.len == 0) {
            sum += calcGroup(lines[start_i..i]);
            start_i = i + 1;
        }
    }
    if (start_i < lines.len) {
        sum += calcGroup(lines[start_i..]);
    }
    return sum;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    debug.assert(gpa.detectLeaks() == false);
    var allocator = gpa.allocator();

    var aocInput = try read_aoc_input(allocator, "input_d13.txt");
    defer aocInput.deinit();

    var sum = calc(aocInput.list.items);
    debug.print("sum: {}\n", .{sum});
}

test "simple test" {
    var allocator = std.testing.allocator;

    var aocInput = try read_aoc_input(allocator, "d13test.txt");
    defer aocInput.deinit();

    var sum = calc(aocInput.list.items);
    debug.assert(sum == 405);
}
