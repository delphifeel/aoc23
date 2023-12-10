const std = @import("std");
const mem = std.mem;
const Allocator = std.mem.Allocator;
const debug = std.debug;
const aoc_input = @import("aoc_input.zig");
const string_view = aoc_input.string_view;
const read_aoc_input = aoc_input.read_aoc_input;

fn parseSeeds(allocator: Allocator, line: string_view) !std.ArrayList(usize) {
    var iter = mem.tokenizeScalar(u8, line, ':');
    _ = iter.next();
    var numbers_str = iter.next() orelse unreachable;
    return try aoc_input.readList(allocator, numbers_str);
}

const Record = [3]usize;
const AssocList = std.ArrayList(Record);

fn parseLocation(seed: usize, all_lists: [][]Record) usize {
    //debug.print("parse seed: {}\n\n{any}\n", .{ seed, all_lists });

    var next_number = seed;
    // 50 52 48
    // 98 50 2
    for (all_lists) |assoc_list| {
        for (assoc_list) |record| {
            //debug.print("next_number: {}, record: {any}\n", .{ next_number, record });
            var from = record[0];
            var till = record[0] + record[2];
            if ((next_number < from) or (next_number >= till)) {
                continue;
            }

            // found proper range
            next_number = record[1] + (next_number - from);
            break;
        }
    }
    return next_number;
}

fn calc(allocator: Allocator, lines: []const string_view) !usize {
    var seeds = try parseSeeds(allocator, lines[0]);
    defer seeds.deinit();

    // associations
    var seed_to_soil = AssocList.init(allocator);
    var soil_to_fert = AssocList.init(allocator);
    var fert_to_water = AssocList.init(allocator);
    var water_to_light = AssocList.init(allocator);
    var light_to_temp = AssocList.init(allocator);
    var temp_to_humidity = AssocList.init(allocator);
    var humidity_to_location = AssocList.init(allocator);
    var all_lists = [7]*AssocList{
        &seed_to_soil,
        &soil_to_fert,
        &fert_to_water,
        &water_to_light,
        &light_to_temp,
        &temp_to_humidity,
        &humidity_to_location,
    };

    var curr_list_index: usize = 0;
    var curr_list = all_lists[curr_list_index];
    var map_lines = lines[3..];

    var i: usize = 0;

    // fill associations
    while (i < map_lines.len) {
        var line_raw = map_lines[i];
        i += 1;
        var line = mem.trim(u8, line_raw, "\r\n ");
        if (line.len == 0) {
            curr_list_index += 1;
            curr_list = all_lists[curr_list_index];
            i += 1;
            continue;
        }
        var l = try aoc_input.readList(allocator, line);
        defer l.deinit();
        var n = l.items;
        try curr_list.append(.{ n[1], n[0], n[2] });
    }

    var all_lists_slices = [7][]Record{
        try seed_to_soil.toOwnedSlice(),
        try soil_to_fert.toOwnedSlice(),
        try fert_to_water.toOwnedSlice(),
        try water_to_light.toOwnedSlice(),
        try light_to_temp.toOwnedSlice(),
        try temp_to_humidity.toOwnedSlice(),
        try humidity_to_location.toOwnedSlice(),
    };
    defer {
        for (all_lists_slices) |sl| {
            allocator.free(sl);
        }
    }

    // actual calculations
    var min_location: ?usize = null;
    for (seeds.items) |seed| {
        var location_v = parseLocation(seed, &all_lists_slices);
        if (min_location) |min| {
            if (location_v < min) {
                min_location = location_v;
            }
        } else {
            min_location = location_v;
        }
    }
    return min_location orelse unreachable;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    debug.assert(gpa.detectLeaks() == false);
    var allocator = gpa.allocator();

    var aocInput = try read_aoc_input(allocator, "input_d5.txt");
    defer aocInput.deinit();

    var sum = try calc(allocator, aocInput.list.items);
    debug.print("sum: {}\n", .{sum});
}

test "simple test" {
    var allocator = std.testing.allocator;

    var aocInput = try read_aoc_input(allocator, "d5test.txt");
    defer aocInput.deinit();

    var sum = try calc(allocator, aocInput.list.items);
    debug.print("sum: {}\n", .{sum});
    debug.assert(sum == 35);
}
