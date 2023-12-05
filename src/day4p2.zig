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

fn parseCardId(line: string_view) usize {
    var token_iter = mem.tokenizeScalar(u8, line, ':');
    var token = token_iter.next() orelse unreachable;
    token = mem.trim(u8, token, " \n\r");
    token_iter = mem.tokenizeScalar(u8, token, ' ');
    _ = token_iter.next();
    var id_str = token_iter.next() orelse unreachable;
    return std.fmt.parseInt(usize, id_str, 10) catch unreachable;
}

// Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
fn calc_card(allocator: Allocator, cards: []const string_view, card_id: usize, cache: *std.AutoHashMap(usize, usize)) !usize {
    if (cache.contains(card_id)) {
        return cache.get(card_id) orelse unreachable;
    }

    var line = cards[card_id - 1];
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

    //debug.print("matches: {any}\n", .{intersection.items});
    var result = intersection.items.len;
    try cache.put(card_id, result);
    return result;
}

fn calc(allocator: Allocator, cards: *std.ArrayList(string_view)) !usize {
    var cache = std.AutoHashMap(usize, usize).init(allocator);
    defer cache.deinit();
    var sum: usize = 0;
    var queue = try cards.clone();
    defer queue.deinit();
    while (queue.items.len > 0) {
        sum += 1;
        var elem = queue.swapRemove(0);
        //debug.print("process {s}\n", .{elem});
        var card_id = parseCardId(elem);
        var win_count = try calc_card(allocator, cards.items, card_id, &cache);
        for (0..win_count) |n| {
            var new_card_id = n + card_id + 1;
            if (new_card_id <= cards.items.len) {
                //debug.print("adding card {}\n", .{new_card_id});
                try queue.append(cards.items[new_card_id - 1]);
            }
        }
    }
    return sum;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    debug.assert(gpa.detectLeaks() == false);
    var allocator = gpa.allocator();

    var aocInput = try read_aoc_input(allocator, "input_d4.txt");
    defer aocInput.deinit();

    var sum = try calc(allocator, &aocInput.list);
    debug.print("sum: {}\n", .{sum});
}

test "simple test" {
    var allocator = std.testing.allocator;

    var aocInput = try read_aoc_input(allocator, "d4test.txt");
    defer aocInput.deinit();

    var sum = try calc(allocator, &aocInput.list);
    debug.assert(sum == 30);
}
