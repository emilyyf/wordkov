const std = @import("std");
const DefaultPrng = std.rand.DefaultPrng;
const Random = std.rand.Random;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const allocator = std.heap.page_allocator;
    var prng = DefaultPrng.init(undefined);
    const random = prng.random();

    var word = [_]u8{0} ** 10;
    var transformation_table: [27][27]u32 = undefined;
    const file = try std.fs.cwd().openFile("words.txt", .{});
    defer file.close();

    for (transformation_table, 0..) |_, i| {
        transformation_table[i] = [_]u32{0} ** 27;
    }

    const rdr = file.reader();
    var line_no: usize = 0;
    while (try rdr.readUntilDelimiterOrEofAlloc(allocator, '\n', 4096)) |line| {
        defer allocator.free(line);

        line_no += 1;
        for (line, 0..) |byte, i| {
            const current = byte - 96;
            const next = if (i == line.len - 1) 26 else line[i+1] - 96;
            transformation_table[current][next] += 1;
        }
    }

    word[0] = random.uintLessThan(u8, 25);

    for (1..word.len) |i| {
        const new_index = @as(
            u8,
            @intCast(
                random.weightedIndex(u32, &transformation_table[word[i-1]])
            )
        );
        if (new_index == 26) {
            break;
        } else {
            word[i] = new_index;
        }
    }

    for (0..word.len) |i| {
        word[i] = if (word[i] > 0) word[i] + 96 else 0;
    }

    try stdout.print("Word: {s}\n", .{ word });
}
