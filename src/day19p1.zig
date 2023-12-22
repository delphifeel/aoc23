const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;
const Allocator = std.mem.Allocator;
const debug = std.debug;
const aoc_input = @import("aoc_input.zig");
const string_view = aoc_input.string_view;
const read_aoc_input = aoc_input.read_aoc_input;

const CmpOp = struct {
    left: u8,
    right: isize,
    sign: u8,
    goto: string_view,
};

const Op = union(enum) {
    accepted: void,
    rejected: void,
    jump: string_view,
    cmp: CmpOp,
};

fn doPartsWork(
    workflows: *const std.StringHashMap(std.ArrayList(Op)),
    parts_values: []const usize,
) bool {
    // start from in
    var curr_flow = workflows.getPtr("in").?;

    debug.print("\n---x={} m={} a={} s={}\n", .{
        parts_values['x'],
        parts_values['m'],
        parts_values['a'],
        parts_values['s'],
    });
    while (true) {
        for (curr_flow.items) |op| {
            switch (op) {
                Op.accepted => return true,
                Op.rejected => return false,
                Op.jump => |s| {
                    debug.print("jump: {s}\n", .{s});
                    curr_flow = workflows.getPtr(s).?;
                    break;
                },
                Op.cmp => |*cmp_op| {
                    var left_v = parts_values[cmp_op.left];
                    var right_v = cmp_op.right;
                    var ok: bool = undefined;
                    if (cmp_op.sign == '<') {
                        ok = left_v < right_v;
                    } else {
                        ok = left_v > right_v;
                    }
                    if (ok) {
                        debug.print("goto: {s}\n", .{cmp_op.goto});
                        if (cmp_op.goto[0] == 'A') {
                            return true;
                        }
                        if (cmp_op.goto[0] == 'R') {
                            return false;
                        }
                        curr_flow = workflows.getPtr(cmp_op.goto).?;
                        break;
                    }
                },
            }
        }
    }
    unreachable;
}

fn calc(allocator: Allocator, lines: [][]u8) usize {
    var workflows = std.StringHashMap(std.ArrayList(Op)).init(allocator);
    defer {
        var iter = workflows.iterator();
        while (iter.next()) |e| {
            e.value_ptr.deinit();
        }
        workflows.deinit();
    }
    var pos: usize = 0;
    for (lines, 0..) |line, i| {
        if (line.len == 0) {
            pos = i;
            break;
        }
        var iter = mem.tokenizeAny(u8, line, "{},");
        var key = iter.next().?;
        workflows.put(key, std.ArrayList(Op).init(allocator)) catch unreachable;
        var list = workflows.getPtr(key).?;

        while (iter.next()) |v| {
            var op_iter = mem.tokenizeScalar(u8, v, ':');
            var v1 = op_iter.next().?;
            var v2 = op_iter.next();
            if (v2) |v2_v| {
                var left_iter = mem.tokenizeAny(u8, v1, "<>");
                var variable = left_iter.next().?;
                var value = fmt.parseInt(isize, left_iter.next().?, 10) catch unreachable;
                var goto = v2_v;
                list.append(.{ .cmp = .{
                    .left = variable[0],
                    .right = value,
                    .sign = v1[1],
                    .goto = goto,
                } }) catch unreachable;
            } else {
                switch (v1[0]) {
                    'A' => list.append(.{ .accepted = {} }) catch unreachable,
                    'R' => list.append(.{ .rejected = {} }) catch unreachable,
                    else => list.append(.{ .jump = v1 }) catch unreachable,
                }
            }
        }
    }

    // var iter = workflows.iterator();
    // while (iter.next()) |e| {
    //     debug.print("[{s}] {any}\n", .{ e.key_ptr.*, e.value_ptr.items });
    // }

    var sum: usize = 0;
    var parts_values = [_]usize{0} ** 256;
    const parts = "xmas";
    var parts_lines = lines[pos + 1 ..];
    for (parts_lines) |line| {
        var iter = mem.tokenizeAny(u8, line, "{},");
        while (iter.next()) |s| {
            var s_iter = mem.tokenizeScalar(u8, s, '=');
            var k = s_iter.next().?;
            var v = s_iter.next().?;
            parts_values[k[0]] = fmt.parseUnsigned(usize, v, 10) catch unreachable;
        }
        var ok = doPartsWork(&workflows, &parts_values);
        if (ok) {
            for (parts) |p| {
                sum += parts_values[p];
            }
        }
    }

    return sum;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    debug.assert(gpa.detectLeaks() == false);
    var allocator = gpa.allocator();

    var aocInput = try read_aoc_input(allocator, "input_d19.txt");
    defer aocInput.deinit();
    var sum = calc(allocator, aocInput.list.items);
    debug.print("REAL sum: {}\n", .{sum});
}

test "simple test" {
    var allocator = std.testing.allocator;

    var aocInput = try read_aoc_input(allocator, "d19test.txt");
    defer aocInput.deinit();

    var sum = calc(allocator, aocInput.list.items);
    _ = sum;
    // debug.assert(sum == 62);
}
