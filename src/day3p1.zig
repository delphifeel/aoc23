const std = @import("std");
const Allocator = std.mem.Allocator;
const debug = std.debug;
const ascii = std.ascii;
const isDigit = std.ascii.isDigit;
const AocInput = @import("aoc_input.zig");

const string_view = []const u8;

fn is_sign(c: u8) bool {
    // number
    if ((c > 47) and (c < 58)) {
        return false;
    }
    if (c == '.') {
        return false;
    }
    return ascii.isPrint(c);
}

fn calc_part_number(lines: *std.ArrayList(string_view), line_index: usize, l: ?usize, r: ?usize) !usize {
    var from_i = l orelse return 0;
    var till_i = r orelse return 0;
    var line = lines.items[line_index];
    var number_as_str = line[from_i..till_i];
    var number = try std.fmt.parseUnsigned(usize, number_as_str, 10);
    var lines_count = lines.items.len;

    // check prev. line
    if (line_index > 0) {
        var prev_line = lines.items[line_index - 1];
        var left: usize = 0;
        if (from_i > 0) {
            left = from_i - 1;
        }
        var right = prev_line.len - 1;
        if (till_i < prev_line.len) {
            right = till_i;
        }

        //debug.print("line: {s}, left: {}, right: {}\n", .{ prev_line, left, right });
        for (left..(right + 1)) |i| {
            if (is_sign(prev_line[i])) {
                return number;
            }
        }
    }

    // check curr. line
    if (from_i > 0) {
        var left = from_i - 1;
        if (is_sign(line[left])) {
            return number;
        }
    }
    if (till_i < line.len) {
        var right = till_i;
        if (is_sign(line[right])) {
            return number;
        }
    }

    // check next line
    if (line_index < lines_count - 1) {
        var next_line = lines.items[line_index + 1];
        var left: usize = 0;
        if (from_i > 0) {
            left = from_i - 1;
        }
        var right = next_line.len - 1;
        if (till_i < next_line.len) {
            right = till_i;
        }

        for (left..(right + 1)) |i| {
            if (is_sign(next_line[i])) {
                return number;
            }
        }
    }

    return 0;
}

fn calc(lines: *std.ArrayList(string_view)) !usize {
    var sum: usize = 0;
    for (lines.items, 0..) |line, line_index| {
        debug.print("{s}\n", .{line});
        var start_index: ?usize = null;
        var end_index: ?usize = null;

        for (line, 0..) |c, i| {
            if (isDigit(c) and (start_index == null)) {
                start_index = i;
                //debug.print("{}\n", .{start_index});
                continue;
            }
            if (!isDigit(c)) {
                if (start_index != null) {
                    end_index = i;
                    sum += try calc_part_number(lines, line_index, start_index, end_index);
                    start_index = null;
                    end_index = null;
                }
            }
        }
        if (start_index != null) {
            end_index = line.len;
            sum += try calc_part_number(lines, line_index, start_index, end_index);
        }
    }
    return sum;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    debug.assert(gpa.detectLeaks() == false);
    var allocator = gpa.allocator();

    var aocInput = try AocInput.read_aoc_input(allocator, "input_d3.txt");
    defer aocInput.deinit();

    var sum = try calc(&aocInput.list);
    debug.print("sum: {}\n", .{sum});
}

test "simple test" {
    var allocator = std.testing.allocator;

    var aocInput = try AocInput.read_aoc_input(allocator, "d3test.txt");
    defer aocInput.deinit();

    var sum = try calc(&aocInput.list);
    debug.assert(sum == 4361);
}
