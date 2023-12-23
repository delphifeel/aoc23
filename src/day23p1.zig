const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;
const Allocator = std.mem.Allocator;
const debug = std.debug;
const aoc_input = @import("aoc_input.zig");
const string_view = aoc_input.string_view;
const read_aoc_input = aoc_input.read_aoc_input;

fn isPossible(lines: [][]u8, pos: [2]isize, old_pos: [2]isize, prev_pos: [2]isize, visited: []bool) bool {
    _ = visited;
    //debug.print("check {any}\n", .{pos});
    if ((pos[0] == -1) or (pos[0] == lines.len)) {
        return false;
    }
    if ((pos[1] == -1) or (pos[1] == lines[0].len)) {
        return false;
    }
    var y: usize = @intCast(pos[0]);
    var x: usize = @intCast(pos[1]);
    var cols: usize = lines[0].len;
    _ = cols;
    if ((pos[0] == prev_pos[0]) and (pos[1] == prev_pos[1])) {
        return false;
    }
    var c = lines[y][x];
    var ok = switch (c) {
        '#' => false,
        '<' => old_pos[1] >= pos[1],
        '>' => old_pos[1] <= pos[1],
        '^' => old_pos[0] >= pos[0],
        'v' => old_pos[0] <= pos[0],
        else => true,
    };

    if (ok) {
        //debug.print("{any} -> OK\n", .{pos});
    }
    return ok;
}

// fn copyVisited(allocator: Allocator, src: []bool) []bool {
//     return allocator.dupe(bool, src) catch unreachable;
// }

fn traverse(allocator: Allocator, lines: [][]u8, pos: [2]isize, prev_pos_old: [2]isize, end_pos: [2]isize, steps: usize, visited: []bool) void {
    //debug.print("traverse\n", .{});
    var curr_pos = [2]isize{ pos[0], pos[1] };
    var posible_pos = [2]isize{ -1, -1 };
    var old_pos = [2]isize{ pos[0], pos[1] };
    var steps_new = steps;
    var prev_pos = prev_pos_old;

    while ((curr_pos[0] != end_pos[0]) or (curr_pos[1] != end_pos[1])) {
        //debug.print("\ncurr_pos: {any}\nsteps: {}\n", .{ curr_pos, steps_new });
        // var y: usize = @intCast(curr_pos[0]);
        // var x: usize = @intCast(curr_pos[1]);
        // var cols = lines[0].len;
        // visited[y * cols + x] = true;

        var curr_pos_set = false;
        old_pos[0] = curr_pos[0];
        old_pos[1] = curr_pos[1];

        // check top
        posible_pos[0] = old_pos[0] - 1;
        posible_pos[1] = old_pos[1];
        if (isPossible(lines, posible_pos, old_pos, prev_pos, visited)) {
            if (curr_pos_set) {
                traverse(allocator, lines, posible_pos, old_pos, end_pos, steps_new + 1, visited);
            } else {
                curr_pos[0] = posible_pos[0];
                curr_pos[1] = posible_pos[1];
                //debug.print("set curr_pos: {any}, prev_pos: {any}\n", .{ curr_pos, prev_pos });
                curr_pos_set = true;
            }
        }
        // check right
        posible_pos[0] = old_pos[0];
        posible_pos[1] = old_pos[1] + 1;
        if (isPossible(lines, posible_pos, old_pos, prev_pos, visited)) {
            if (curr_pos_set) {
                traverse(allocator, lines, posible_pos, old_pos, end_pos, steps_new + 1, visited);
            } else {
                curr_pos[0] = posible_pos[0];
                curr_pos[1] = posible_pos[1];
                curr_pos_set = true;
                //debug.print("set curr_pos: {any}, prev_pos: {any}\n", .{ curr_pos, prev_pos });
            }
        }
        // check bottom
        posible_pos[0] = old_pos[0] + 1;
        posible_pos[1] = old_pos[1];
        if (isPossible(lines, posible_pos, old_pos, prev_pos, visited)) {
            if (curr_pos_set) {
                traverse(allocator, lines, posible_pos, old_pos, end_pos, steps_new + 1, visited);
            } else {
                curr_pos[0] = posible_pos[0];
                curr_pos[1] = posible_pos[1];
                curr_pos_set = true;
                //debug.print("set curr_pos: {any}, prev_pos: {any}\n", .{ curr_pos, prev_pos });
            }
        }
        // check left
        posible_pos[0] = old_pos[0];
        posible_pos[1] = old_pos[1] - 1;
        if (isPossible(lines, posible_pos, old_pos, prev_pos, visited)) {
            if (curr_pos_set) {
                traverse(allocator, lines, posible_pos, old_pos, end_pos, steps_new + 1, visited);
            } else {
                curr_pos[0] = posible_pos[0];
                curr_pos[1] = posible_pos[1];
                curr_pos_set = true;
                //debug.print("set curr_pos: {any}, prev_pos: {any}\n", .{ curr_pos, prev_pos });
            }
        }

        prev_pos[0] = old_pos[0];
        prev_pos[1] = old_pos[1];

        steps_new += 1;
        if (!curr_pos_set) {
            break;
        }
    }

    debug.print("steps: {}\n", .{steps_new});
}

fn calc(allocator: Allocator, lines: [][]u8) usize {
    // find start, end pos
    var start_x: isize = @intCast(mem.indexOfScalar(u8, lines[0], '.').?);
    var end_x: isize = @intCast(mem.indexOfScalar(u8, lines[lines.len - 1], '.').?);

    var start_pos = [_]isize{ 0, start_x };
    var end_y: isize = @intCast(lines.len - 1);
    var end_pos = [_]isize{ end_y, end_x };

    var steps: usize = 0;
    var visited_size = lines.len * lines[0].len;
    var visited = allocator.alloc(bool, visited_size) catch unreachable;
    for (visited) |*v| {
        v.* = false;
    }
    defer allocator.free(visited);
    traverse(allocator, lines, start_pos, start_pos, end_pos, steps, visited);

    return 0;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    debug.assert(gpa.detectLeaks() == false);
    var allocator = gpa.allocator();

    var aocInput = try read_aoc_input(allocator, "input_d23.txt");
    defer aocInput.deinit();
    var sum = calc(allocator, aocInput.list.items);
    _ = sum;
    //debug.print("REAL sum: {}\n", .{sum});
}

test "simple test" {
    var allocator = std.testing.allocator;

    var aocInput = try read_aoc_input(allocator, "d23test.txt");
    defer aocInput.deinit();

    var sum = calc(allocator, aocInput.list.items);
    _ = sum;
    // debug.assert(sum == 62);
}
