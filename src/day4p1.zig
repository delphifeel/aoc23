const std = @import("std");
const mem = std.mem;
const Allocator = std.mem.Allocator;
const debug = std.debug;
const aoc_input = @import("aoc_input.zig");
const string_view = aoc_input.string_view;
const read_aoc_input = aoc_input.read_aoc_input;

fn readList(allocator: Allocator, str: string_view) !std.ArrayList(usize) {
    var iter = mem.tokenizeScalar(u8, str, ' ');
    var list = std.ArrayList(usize).init(allocator);
    errdefer list.deinit();
    while (iter.next()) |raw| {
        var s = mem.trim(u8, raw, "\n\r ");
        var v = std.fmt.parseInt(usize, s, 10) catch continue;
        try list.append(v);
    }
    return list;
}

// Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
fn calc_game(allocator: Allocator, line: string_view) !usize {
    var token_iter = mem.tokenizeScalar(u8, line, ':');
    _ = token_iter.next();
    var token = token_iter.next() orelse unreachable;
    token_iter = mem.tokenizeScalar(u8, token, '|');
    var winnable_str = token_iter.next() orelse unreachable;
    var have_str = token_iter.next() orelse unreachable;

    var winnable_list = try readList(allocator, winnable_str);
    defer winnable_list.deinit();

    var have_list = try readList(allocator, have_str);
    defer have_list.deinit();

    var intersection = std.ArrayList(usize).init(allocator);
    defer intersection.deinit();

    for (have_list.items) |item| {
        var i = mem.indexOfScalar(usize, winnable_list.items, item) orelse continue;
        try intersection.append(winnable_list.items[i]);
    }

    var sum: usize = 0;
    for (intersection.items, 0..) |_, i| {
        if (i == 0) {
            sum = 1;
        } else {
            sum *= 2;
        }
    }

    return sum;
}

fn calc(allocator: Allocator, input_list: []const string_view) !usize {
    var sum: usize = 0;
    for (input_list) |line| {
        sum += try calc_game(allocator, line);
    }
    return sum;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    debug.assert(gpa.detectLeaks() == false);
    var allocator = gpa.allocator();

    var aocInput = try read_aoc_input(allocator, "input_d4.txt");
    defer aocInput.deinit();

    var sum = try calc(allocator, aocInput.list.items);
    debug.print("sum: {}\n", .{sum});
}

test "simple test" {
    var allocator = std.testing.allocator;

    var aocInput = try read_aoc_input(allocator, "d4test.txt");
    defer aocInput.deinit();

    var sum = try calc(allocator, aocInput.list.items);
    debug.assert(sum == 13);
}
