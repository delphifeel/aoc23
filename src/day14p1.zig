const std = @import("std");
const mem = std.mem;
const Allocator = std.mem.Allocator;
const debug = std.debug;
const aoc_input = @import("aoc_input.zig");
const string_view = aoc_input.string_view;
const read_aoc_input = aoc_input.read_aoc_input;

fn calc(allocator: Allocator, lines: []const string_view) usize {
    var cols_count = lines[0].len;
    var rows_count = lines.len;

    // init last rock info
    var last_rock_row = allocator.alloc(?usize, cols_count) catch unreachable;
    defer allocator.free(last_rock_row);
    for (last_rock_row) |*item| {
        item.* = null;
    }

    // init last rounder info
    // var last_rounded_row = allocator.alloc(?usize, cols_count) catch unreachable;
    // defer allocator.free(last_rounded_row);
    // for (last_rounded_row) |*item| {
    //     item.* = null;
    // }

    var sum: usize = 0;
    for (lines, 0..) |line, i| {
        var row = rows_count - i;
        for (line, 0..) |c, col| {
            if (c == 'O') {
                if (last_rock_row[col]) |row_v| {
                    last_rock_row[col] = row_v - 1;
                } else {
                    last_rock_row[col] = rows_count;
                }

                sum += last_rock_row[col] orelse unreachable;
                continue;
            }
            if (c == '#') {
                last_rock_row[col] = row;
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
    debug.print("sum: {}\n", .{sum});
}

test "simple test" {
    var allocator = std.testing.allocator;

    var aocInput = try read_aoc_input(allocator, "d14test.txt");
    defer aocInput.deinit();

    var sum = calc(allocator, aocInput.list.items);
    debug.assert(sum == 136);
}
