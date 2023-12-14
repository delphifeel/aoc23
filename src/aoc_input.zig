const std = @import("std");
const mem = std.mem;
const Allocator = std.mem.Allocator;
pub const string_view = []const u8;

const Self = @This();
allocator: Allocator,
list: std.ArrayList([]u8),

pub fn deinit(self: *Self) void {
    for (self.list.items) |item| {
        self.allocator.free(item);
    }
    self.list.deinit();
}

pub fn read_aoc_input(allocator: Allocator, file_name: string_view) !Self {
    var file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();
    var buf: [3000]u8 = undefined;
    var list = std.ArrayList([]u8).init(allocator);
    var self = Self{ .allocator = allocator, .list = list };
    errdefer self.deinit();
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var line_copy = try allocator.dupe(u8, line);
        try self.list.append(line_copy);
    }

    return self;
}

pub fn readList(allocator: Allocator, str: string_view) !std.ArrayList(usize) {
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
