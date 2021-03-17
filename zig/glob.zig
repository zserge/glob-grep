const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
var alloc = std.heap.GeneralPurposeAllocator(.{}){};

fn glob(pattern: []const u8, text: []const u8) bool {
    var p: usize = 0;
    var t: usize = 0;
    var np: usize = 0;
    var nt: usize = 0;
    while (p < pattern.len or t < text.len) {
        if (p < pattern.len) {
            switch (pattern[p]) {
                '*' => {
                    np = p;
                    nt = t + 1;
                    p += 1;
                    continue;
                },
                '?' => {
                    if (nt < text.len) {
                        p += 1;
                        t += 1;
                        continue;
                    }
                },
                else => {
                    if (t < text.len and text[t] == pattern[p]) {
                        p += 1;
                        t += 1;
                        continue;
                    }
                },
            }
        }
        if (nt > 0 and nt <= text.len) {
            p = np;
            t = nt;
            continue;
        }
        return false;
    }
    return true;
}

test "glob" {
    expect(glob("", ""));
    expect(glob("hello", "hello"));
    expect(glob("h??lo", "hello"));
    expect(glob("h*o", "hello"));
    expect(glob("h*ello", "hello"));
    expect(glob("*h*o*", "hello world"));
    expect(glob("h*o*", "hello world"));
    expect(glob("*h*d", "hello world"));
    expect(glob("*h*l*w*d", "hello world"));
    expect(glob("*h?l*w*d", "hello world"));

    expect(!glob("hello", "hi"));
    expect(!glob("h?i", "hi"));
    expect(!glob("h*l", "hello"));
}

fn walk(allocator: *std.mem.Allocator, path: []const u8, pattern: []const u8) anyerror!void {
    var walker = try std.fs.walkPath(allocator, ".");
    defer walker.deinit();
    while (try walker.next()) |entry| {
        if (entry.kind == .File) {
            const file = try entry.dir.openFile(entry.basename, .{});
            defer file.close();
            const text = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
            defer allocator.free(text);
            if (std.mem.indexOf(u8, text, "\x00") != null or std.mem.indexOf(u8, text, "\n") == null) {
                continue;
            }

            var lines = std.mem.tokenize(text, "\n");
            var lineno: usize = 1;
            while (lines.next()) |line| : (lineno += 1) {
                if (glob(pattern, line)) {
                    print("{s}:{d}\t{s}\n", .{ entry.path, lineno, line });
                }
            }
        }
    }
}

pub fn main() anyerror!void {
    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    if (args.len != 2) {
        std.log.err("USAGE: {s} <pattern>", .{args[0]});
        return;
    }
    try walk(allocator, ".", args[1]);
}
