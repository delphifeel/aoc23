const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;
const Allocator = std.mem.Allocator;
const debug = std.debug;
const aoc_input = @import("aoc_input.zig");
const string_view = aoc_input.string_view;
const read_aoc_input = aoc_input.read_aoc_input;

// [4]isize - x, y, vx, vy

fn compareData(data1: [4]isize, data2: [4]isize, min: f64, max: f64) bool {
    var x1: f64 = @floatFromInt(data1[0]);
    var y1: f64 = @floatFromInt(data1[1]);
    var vx1: f64 = @floatFromInt(data1[2]);
    var vy1: f64 = @floatFromInt(data1[3]);

    var x2: f64 = @floatFromInt(data2[0]);
    var y2: f64 = @floatFromInt(data2[1]);
    var vx2: f64 = @floatFromInt(data2[2]);
    var vy2: f64 = @floatFromInt(data2[3]);

    // x1 + t*vx1 = x2 + t*vx2
    // y1 + t*vy1 = y2 + t*vy2
    // get rid of t (left side for ex.)

    // vx1*t + vy1*t*s = 0
    // s = -vx1 / vy1
    var s: f64 = -vx1 / vy1;

    // x1 + t*vx1 = x2 + t*vx2
    //            +
    // s*y1 + s*t*vy1 = s*y2 + s*t*vy2

    // (x1 + s*y1) + (t*vx1 + s*t*vy1) = (x2 + s*y2) + (t*vx2 + s*t*vy2)
    // (t*vx1 + s*t*vy1) - (t*vx2 + s*t*vy2) = (x2 + s*y2) - (x1 + s*y1)
    // t*vx1 + s*t*vy1 - t*vx2 - s*t*vy2 = x2 + s*y2 - x1 - s*y1
    // t(vx1 + s*vy1 - vx2 - s*vy2) = x2 + s*y2 - x1 - s*y1
    // t = (x2 + s*y2 - x1 - s*y1) / (vx1 + s*vy1 - vx2 - s*vy2)
    var t = (x2 + s * y2 - x1 - s * y1) / (vx1 + s * vy1 - vx2 - s * vy2);

    // apply to right side
    // x = x2 + t*vx2
    // y = y2 + t*vy2

    if (@abs(t) == std.math.inf(f64)) {
        return false;
    }

    var x = x2 + t * vx2;
    var y = y2 + t * vy2;

    debug.print("x: {d}, y: {d}\n", .{ x, y });

    if (x < min or x > max or y < min or y > max) {
        return false;
    }

    return true;
}

fn calc(allocator: Allocator, lines: [][]u8, min: f64, max: f64) usize {
    // format data
    var data = std.ArrayList([4]isize).initCapacity(allocator, lines.len) catch unreachable;
    defer data.deinit();
    for (lines) |line| {
        var iter = mem.tokenizeAny(u8, line, "@ ,");
        var x = fmt.parseInt(isize, iter.next().?, 10) catch unreachable;
        var y = fmt.parseInt(isize, iter.next().?, 10) catch unreachable;
        // z - skip
        _ = iter.next();
        var vx = fmt.parseInt(isize, iter.next().?, 10) catch unreachable;
        var vy = fmt.parseInt(isize, iter.next().?, 10) catch unreachable;

        data.append(.{ x, y, vx, vy }) catch unreachable;
    }

    var visited = allocator.alloc(bool, lines.len) catch unreachable;
    defer allocator.free(visited);
    @memset(visited, false);

    var sum: usize = 0;
    for (0..data.items.len) |i| {
        for ((i + 1)..data.items.len) |j| {
            if (visited[i] or visited[j]) {
                continue;
            }

            if (compareData(data.items[i], data.items[j], min, max)) {
                visited[i] = true;
                visited[j] = true;
                sum += 1;
            }
        }
    }

    return sum;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    debug.assert(!gpa.detectLeaks());
    var allocator = gpa.allocator();

    var aocInput = try read_aoc_input(allocator, "input_24.txt");
    defer aocInput.deinit();
    var sum = calc(allocator, aocInput.list.items, 200000000000000, 400000000000000);
    debug.print("REAL sum: {}\n", .{sum});
}

test "simple test" {
    var allocator = std.testing.allocator;

    var aocInput = try read_aoc_input(allocator, "d24test.txt");
    defer aocInput.deinit();

    var sum = calc(allocator, aocInput.list.items, 7, 27);
    debug.assert(sum == 2);
}
