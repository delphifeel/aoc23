const std = @import("std");
const mem = std.mem;
const Allocator = std.mem.Allocator;
const debug = std.debug;
const aoc_input = @import("aoc_input.zig");
const string_view = aoc_input.string_view;
const read_aoc_input = aoc_input.read_aoc_input;

fn calcLine(allocator: Allocator, row: string_view, numbers: []const usize) !usize {
    _ = numbers;
    var row_mut = try allocator.dupe(u8, row);
    defer allocator.free(row_mut);

    // split to groups without .
    var groups = std.ArrayList(string_view).init(allocator);
    defer groups.deinit();
    var iter = mem.tokenizeScalar(u8, row_mut, '.');
    while (iter.next()) |item| {
        try groups.append(item);
    }

    debug.print("{s}\n", .{groups.items});

    // var n_i = 0;
    // _ = n_i;
    // while (1) {
    //     var n = numbers[i];
    //     mem.indexOf(u8, row_mut, )
    // }

    return 0;
}

fn calc(allocator: Allocator, lines: []const string_view) !usize {
    var sum: usize = undefined;
    var numbers = std.ArrayList(usize).init(allocator);
    defer numbers.deinit();
    for (lines) |line| {
        numbers.clearAndFree();
        var iter = mem.tokenizeScalar(u8, line, ' ');
        var row = iter.next() orelse unreachable;
        var number_str = iter.next() orelse unreachable;
        var numbers_iter = mem.tokenizeScalar(u8, number_str, ',');
        while (numbers_iter.next()) |b| {
            try numbers.append(try std.fmt.parseUnsigned(usize, b, 10));
        }
        sum += try calcLine(allocator, row, numbers.items);
    }
    return sum;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    debug.assert(gpa.detectLeaks() == false);
    var allocator = gpa.allocator();

    var aocInput = try read_aoc_input(allocator, "input_d12.txt");
    defer aocInput.deinit();

    var sum = try calc(allocator, aocInput.list.items);
    _ = sum;
}

test "simple test" {
    var allocator = std.testing.allocator;

    var aocInput = try read_aoc_input(allocator, "d12test.txt");
    defer aocInput.deinit();

    var sum = try calc(allocator, aocInput.list.items);
    _ = sum;
    // debug.print("sum: {}\n", .{sum});
    // debug.assert(sum == 46);
    // std.Thread.
}
