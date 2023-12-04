const std = @import("std");
const debug = std.debug;
const isDigit = std.ascii.isDigit;

const string_view = []const u8;

fn process(line: string_view, l: ?usize, r: ?usize) void {
    var l_v = l orelse return;
    var r_v = r orelse return;
    var number_as_str = line[l_v..r_v];
    debug.print("{s}\n", .{number_as_str});
}

fn calc(lines: *std.ArrayList(string_view)) !usize {
    var sum: usize = 0;
    var count = lines.items.len;
    _ = count;
    for (lines.items) |line| {
        debug.print("{s}\n", .{line});
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
                    process(line, start_index, end_index);
                    start_index = null;
                    end_index = null;
                }
            }
        }
        if (start_index != null) {
            end_index = line.len;
            process(line, start_index, end_index);
        }
    }
    return sum;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    debug.assert(gpa.detectLeaks() == false);
    var allocator = gpa.allocator();

    var file = try std.fs.cwd().openFile("d3test.txt", .{});
    defer file.close();

    // Things are _a lot_ slower if we don't use a BufferedReader
    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();
    var buf: [3000]u8 = undefined;
    var lines = std.ArrayList(string_view).init(allocator);
    defer lines.clearAndFree();
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var line_copy = try allocator.dupe(u8, line);
        try lines.append(line_copy);
        // do something with line...
    }

    var a = try calc(&lines);
    _ = a;
}

test "simple test" {
    var allocator = std.testing.allocator;

    var file = try std.fs.cwd().openFile("d3test.txt", .{});
    defer file.close();

    // Things are _a lot_ slower if we don't use a BufferedReader
    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();
    var buf: [16000]u8 = undefined;
    var lines = std.ArrayList(string_view).init(allocator);
    defer lines.deinit();
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        try lines.append(line);
        // do something with line...
    }

    var a = try calc(&lines);
    _ = a;
}
