const std = @import("std");
const Pool = std.Thread.Pool;
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

fn findInside(workflows: *const std.StringHashMap(std.ArrayList(Op)), key: string_view) string_view {
    var iter = workflows.iterator();
    while (iter.next()) |e| {
        var iter_key = e.key_ptr.*;
        for (e.value_ptr.items) |op| {
            switch (op) {
                Op.jump => |s| {
                    if (mem.eql(u8, s, key)) {
                        return iter_key;
                    }
                },
                Op.cmp => |*cmp_op| {
                    if (mem.eql(u8, cmp_op.goto, key)) {
                        return iter_key;
                    }
                },
                else => continue,
            }
        }
    }
    unreachable;
}

fn calc(allocator: Allocator, lines: [][]u8) usize {
    // prepare workflows
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

    // going backward from A
    var w_iter = workflows.iterator();
    while (w_iter.next()) |e| {
        var key = e.key_ptr.*;
        var accept_index: ?usize = null;
        for (e.value_ptr.items, 0..) |op, i| {
            switch (op) {
                Op.accepted => {
                    accept_index = i;
                    break;
                },
                Op.cmp => |*cmp_op| {
                    if (cmp_op.goto[0] == 'A') {
                        accept_index = i;
                        break;
                    }
                },
                else => continue,
            }
        }
        if (accept_index == null) {
            continue;
        }
        var curr_value = e.value_ptr;
        var curr_key = key;
        var next_key: string_view = "A";
        var buff: [1024]u8 = undefined;
        var done = false;
        var str = std.ArrayList(u8).initCapacity(allocator, 1024) catch unreachable;
        defer str.deinit();
        while (!done) {
            // debug.print("curr_key: {s}, next_key: {s}\n", .{ curr_key, next_key });
            for (curr_value.items) |op| {
                //debug.print("curr_key: {s}, next_key: {s}\n", .{ curr_key, next_key });
                switch (op) {
                    Op.accepted => {
                        if (mem.eql(u8, next_key, "A")) {
                            next_key = curr_key;
                            curr_key = findInside(&workflows, curr_key);
                            curr_value = workflows.getPtr(curr_key).?;
                            break;
                        }
                    },
                    Op.jump => |s| {
                        // debug.print("jump. s: {s}, curr_key: {s}, next_key: {s}\n", .{ s, curr_key, next_key });
                        if (mem.eql(u8, s, next_key)) {
                            next_key = curr_key;
                            if (mem.eql(u8, next_key, "in")) {
                                done = true;
                                break;
                            }
                            curr_key = findInside(&workflows, curr_key);
                            curr_value = workflows.getPtr(curr_key).?;
                            break;
                        }
                    },
                    Op.cmp => |*cmp_op| {
                        if (mem.eql(u8, cmp_op.goto, next_key)) {
                            var buff_slice =
                                fmt.bufPrint(
                                &buff,
                                "- {c}{c}{}\n",
                                .{ cmp_op.left, cmp_op.sign, cmp_op.right },
                            ) catch unreachable;
                            str.appendSlice(buff_slice) catch unreachable;
                            next_key = curr_key;
                            if (mem.eql(u8, next_key, "in")) {
                                done = true;
                                break;
                            }
                            curr_key = findInside(&workflows, curr_key);
                            curr_value = workflows.getPtr(curr_key).?;
                            break;
                        }

                        var buff_slice =
                            fmt.bufPrint(
                            &buff,
                            "- {c}!{c}{}\n",
                            .{ cmp_op.left, cmp_op.sign, cmp_op.right },
                        ) catch unreachable;
                        str.appendSlice(buff_slice) catch unreachable;
                    },
                    else => continue,
                }
            }
        }
        debug.print("key: {s}\n", .{key});
        debug.print("{s}\n", .{str.items});
    }

    // var iter = workflows.iterator();
    // while (iter.next()) |e| {
    //     debug.print("[{s}] {any}\n", .{ e.key_ptr.*, e.value_ptr.items });
    // }

    // var sum: usize = 0;

    // // YES, I JUST DO THREADS
    // var mutex = std.Thread.Mutex{};
    // var pool = Pool{ .allocator = allocator, .threads = undefined };
    // Pool.init(&pool, .{ .allocator = allocator }) catch unreachable;
    // defer pool.deinit();

    // for (1..4001) |x| {
    //     pool.spawn(doPartsRange, .{ &sum, &mutex, &workflows, x }) catch unreachable;
    // }

    // var wg = std.Thread.WaitGroup{};
    // pool.waitAndWork(&wg);

    // return sum;
    return 0;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    debug.assert(gpa.detectLeaks() == false);
    var allocator = gpa.allocator();

    var aocInput = try read_aoc_input(allocator, "d19test.txt");
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
