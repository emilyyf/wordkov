const std = @import("std");
// const DefaultPrng = std.rand.DefaultPrng;
// const Random = std.rand.Random;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const allocator = std.heap.page_allocator;
    var transformation_table: [27][27]u32 = undefined;
    for (transformation_table, 0..) |_, i| {
        transformation_table[i] = [_]u32{0} ** 27;
    }

    const file = try std.fs.cwd().openFile("words.txt", .{});

    defer file.close();

    const rdr = file.reader();
    var line_no: usize = 0;
    while (try rdr.readUntilDelimiterOrEofAlloc(allocator, '\n', 4096)) |line| {
        defer allocator.free(line);

        line_no += 1;
        for (line, 0..) |byte, i| {
            const current = byte - 97;
            const next = if (i == line.len - 1) 26 else line[i+1] - 97;
            transformation_table[current][next] += 1;
        }
    }

    for (0..26) |i| {
        try stdout.print("{c}\t", .{ @as(u8, @intCast(97 + i)) });
    }
    try stdout.print("\n", .{});
    for (transformation_table, 0..) |row, i| {
        try stdout.print("{c} ", .{ @as(u8, @intCast(97 + i)) });
        for (row) |xxx| {
            try stdout.print("{d}\t", .{ xxx });
        }
        try stdout.print("\n", .{});
    }
}
