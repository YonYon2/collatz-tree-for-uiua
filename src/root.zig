//! By convention, root.zig is the root source file when making a package.
const std = @import("std");
const Io = std.Io;

pub const Edge = struct {
    v0: usize = 0,
    v1: usize = 0,
};

pub const Edges = std.ArrayList(Edge);
pub const Tree = std.AutoHashMap(usize, std.ArrayList(usize));

pub fn generateCollatzBranches(allocator: std.mem.Allocator, tree: *Tree, N: usize) !void {
    // 1 to N-1
    std.debug.print("1 - N but odd:", .{});
    for (1..(N + 1) / 2) |x_count| {
        const x = 2 * x_count + 1;
        std.debug.print(" {}", .{x});
        try tree.put(x, .empty);
        // depth m to double odd root by
        for (0..std.math.log2_int(usize, N / x) + 1) |m| {
            try tree.getEntry(x).?.value_ptr.append(allocator, x * std.math.pow(usize, 2, m));
        }
    }
    // all odd numbers from 3 to N
    std.debug.print("\n3 to N odd:", .{});
    for (0..(N - 1) / 2) |x_count| {
        var x = 2 * x_count + 3;
        std.debug.print(" {}", .{x});
        while (x != 1) {
            // std.debug.print("x:{}", .{x});
            const b = 3 * x + 1;
            const m = b & (~b + 1);
            const y = b / m;
            const yKey = tree.getEntry(y);
            if (yKey) |y_ntry| {
                var b_not_exists = true;
                for (y_ntry.value_ptr.items) |y_iteys| {
                    if (y_iteys == b) {
                        b_not_exists = false;
                        break;
                    }
                }
                // std.debug.print(" b not exists:{}", .{b_not_exists});
                if (b_not_exists) {
                    var power = std.math.pow(usize, 2, y_ntry.value_ptr.items.len);
                    while (y * power <= b) {
                        try y_ntry.value_ptr.append(allocator, y * power);
                        power = power * 2;
                    }
                } else {
                    break;
                }
            } else {
                var power: usize = 1;
                var y_ntry = try tree.getOrPutValue(y, .empty);
                while (y * power <= b) {
                    try y_ntry.value_ptr.append(allocator, y * power);
                    power = power * 2;
                }
            }
            x = y;
        }
    }
}

// edges is initialied before function call
pub fn buildCollatzSubtreeEdges(allocator: std.mem.Allocator, edges: *Edges, tree: Tree) !void {
    var tree_it = tree.iterator();
    // going to ignore the doubling branches
    // while (tree_it.next()) |branch| {
    //     if (branch.value_ptr.items.len > 1) {
    //         for (1..branch.value_ptr.items.len) |i| {
    //             // used to be (child, parent)
    //             try edges.append(allocator, .{ .v1 = branch.value_ptr.items[i], .v0 = branch.value_ptr.items[i - 1] });
    //         }
    //     }
    // }
    // restart iterator
    tree_it = tree.iterator();
    while (tree_it.next()) |branch| {
        const x = branch.key_ptr.*;
        const b = 3 * x + 1;
        // m <- b ^ (-b)
        const m = b & (~b + 1);
        const y = b / m;
        // i = index of b in tree[y]
        const i: ?usize = std.mem.find(usize, tree.get(y).?.items, &[1]usize{b});
        try edges.append(allocator, .{ .v1 = tree.get(x).?.items[0], .v0 = tree.get(y).?.items[i.?] });
    }
    // add trivial cycle
    try edges.append(allocator, .{ .v1 = 1, .v0 = 4 });
}
