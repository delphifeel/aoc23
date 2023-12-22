const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;
const Allocator = std.mem.Allocator;
const debug = std.debug;
const aoc_input = @import("aoc_input.zig");
const string_view = aoc_input.string_view;
const read_aoc_input = aoc_input.read_aoc_input;

const Op = struct {
    label: string_view,
    high: bool,
};

const MapItem = struct {
    sign: u8,
    list: std.ArrayList(string_view),
};
const Map = std.StringHashMap(MapItem);

fn calc(allocator: Allocator, lines: [][]u8) usize {
    var q = std.ArrayList(Op).init(allocator);
    defer q.deinit();

    // make hash map
    var map = Map.init(allocator);
    defer {
        var map_iter = map.iterator();
        while (map_iter.next()) |entry| {
            entry.value_ptr.list.deinit();
        }
        map.deinit();
    }
    for (lines) |line| {
        var iter_data = mem.tokenizeAny(u8, line, " ->,");
        var key = iter_data.next().?;

        if (mem.eql(u8, key, "broadcaster")) {
            while (iter_data.next()) |value| {
                q.append(.{ .label = value, .high = true }) catch unreachable;
            }
            continue;
        }

        var sign = key[0];
        key = key[1..];
        map.put(key, .{
            .sign = sign,
            .list = std.ArrayList(string_view).init(allocator),
        }) catch unreachable;
        var v = map.getPtr(key).?;
        while (iter_data.next()) |label| {
            v.list.append(label) catch unreachable;
        }
    }

    var map_iter = map.iterator();
    while (map_iter.next()) |entry| {
        debug.print("{s}: {c} {any}\n", .{ entry.key_ptr.*, entry.value_ptr.sign, entry.value_ptr.list.items });
    }

    //for (lines)

    return 0;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    debug.assert(gpa.detectLeaks() == false);
    var allocator = gpa.allocator();

    var aocInput = try read_aoc_input(allocator, "d20test.txt");
    defer aocInput.deinit();
    var sum = calc(allocator, aocInput.list.items);
    debug.print("REAL sum: {}\n", .{sum});
}

test "simple test" {
    var allocator = std.testing.allocator;

    var aocInput = try read_aoc_input(allocator, "d20test.txt");
    defer aocInput.deinit();

    var sum = calc(allocator, aocInput.list.items);
    _ = sum;
    // debug.assert(sum == 62);
}
