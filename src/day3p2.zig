const std = @import("std");
const Allocator = std.mem.Allocator;
const debug = std.debug;
const ascii = std.ascii;
const isDigit = std.ascii.isDigit;
const AocInput = @import("aoc_input.zig");

const string_view = []const u8;

fn is_sign(c: u8) bool {
    return c == '*';
}

const GearMap = std.AutoHashMap([2]usize, std.ArrayList(usize));
var map: *GearMap = undefined;

fn append_gear_number(self: *GearMap, allocator: Allocator, key: [2]usize, number: usize) !void {
    var list: *std.ArrayList(usize) = undefined;
    if (self.contains(key)) {
        list = self.getPtr(key) orelse unreachable;
    } else {
        try self.put(key, std.ArrayList(usize).init(allocator));
        list = self.getPtr(key) orelse unreachable;
    }

    try list.append(number);
}

fn calc_part_number(allocator: Allocator, lines: *std.ArrayList(string_view), line_index: usize, l: ?usize, r: ?usize) !void {
    var from_i = l orelse return;
    var till_i = r orelse return;
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

        for (left..(right + 1)) |i| {
            if (is_sign(prev_line[i])) {
                var key = .{ i, line_index - 1 };
                try append_gear_number(map, allocator, key, number);
                return;
            }
        }
    }

    // check curr. line
    if (from_i > 0) {
        var left = from_i - 1;
        if (is_sign(line[left])) {
            var key = .{ left, line_index };
            try append_gear_number(map, allocator, key, number);
            return;
        }
    }
    if (till_i < line.len) {
        var right = till_i;
        if (is_sign(line[right])) {
            var key = .{ right, line_index };
            try append_gear_number(map, allocator, key, number);
            return;
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
                var key = .{ i, line_index + 1 };
                try append_gear_number(map, allocator, key, number);
                return;
            }
        }
    }
}

fn gear_print() void {
    debug.print("[\n", .{});
    var iter = map.iterator();
    while (iter.next()) |entry| {
        debug.print("{any}: {any}\n", .{ entry.key_ptr.*, entry.value_ptr.items });
    }
    debug.print("]\n", .{});
}

fn calc(allocator: Allocator, lines: *std.ArrayList(string_view)) !usize {
    var map_struct = GearMap.init(allocator);
    defer map_struct.deinit();
    map = &map_struct;

    for (lines.items, 0..) |line, line_index| {
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
                    try calc_part_number(allocator, lines, line_index, start_index, end_index);
                    start_index = null;
                    end_index = null;
                }
            }
        }
        if (start_index != null) {
            end_index = line.len;
            try calc_part_number(allocator, lines, line_index, start_index, end_index);
        }
    }

    var sum: usize = 0;
    var iter = map.iterator();
    while (iter.next()) |e| {
        var items = e.value_ptr.items;
        var numbers_count = items.len;
        if (numbers_count != 2) {
            continue;
        }

        sum += items[0] * items[1];
    }

    return sum;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    debug.assert(gpa.detectLeaks() == false);
    var allocator = gpa.allocator();

    var aocInput = try AocInput.read_aoc_input(allocator, "input_d3.txt");
    defer aocInput.deinit();

    var sum = try calc(allocator, &aocInput.list);
    debug.print("sum: {}\n", .{sum});
}

test "simple test" {
    var allocator = std.testing.allocator;

    var aocInput = try AocInput.read_aoc_input(allocator, "d3test.txt");
    defer aocInput.deinit();

    var sum = try calc(allocator, &aocInput.list);
    debug.print("sum: {}\n", .{sum});
}
