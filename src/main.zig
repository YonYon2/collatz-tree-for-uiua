const std = @import("std");
const collatz_tree = @import("collatz_tree_for_uiua");

pub fn main(init: std.process.Init) !void {
    // Prints to stderr, unbuffered, ignoring potential errors.
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    // upper bound N
    const upper_bound: usize = 1_000_000;
    const allocator = init.arena.allocator();
    var edges = collatz_tree.Edges.init(allocator);
    defer {
        // var edges_val_it = edges.valueIterator();
        // while (edges_val_it.next()) |val| {

        // }
        edges.deinit();
    }
    var tree = collatz_tree.Tree.init(allocator);
    defer {
        var tree_values_it = tree.valueIterator();
        while (tree_values_it.next()) |val| {
            val.deinit(allocator);
        }
        tree.deinit();
    }
    try collatz_tree.generateCollatzBranches(allocator, &tree, upper_bound);
    std.debug.print("cap: {}\n", .{tree.capacity()});
    // var tree_it = tree.iterator();
    // while (tree_it.next()) |entry| {
    //     std.debug.print("{}", .{entry.value_ptr.items[0]});
    //     for (entry.value_ptr.items[1..]) |i| {
    //         std.debug.print("-{}", .{i});
    //     }
    //     std.debug.print("\n", .{});
    // }
    // if it runs, a graph of the collatz tree should be able to be displayed using edges
    try collatz_tree.buildCollatzSubtreeEdges(&edges, tree);

    // var ed_it = edges.iterator();
    // while (ed_it.next()) |entry| {
    //     std.debug.print("{}->{}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    // }

    // depth first search to display edges length-wise (longer = deeper)
    var branch_queue = std.Deque(collatz_tree.Edge).empty;
    defer branch_queue.deinit(allocator);
    // v0 = key, v1 = depth
    try branch_queue.pushBack(allocator, .{ .v0 = 1, .v1 = 0 });
    // ignore 4 branch and traverse all leaf nodes, counting depth
    var current_odd_root: usize = 1;
    var max_dist: usize = 0;
    max_dist = 0;
    var curr_dist: usize = 0;
    var run = true;
    while (run) {
        const info = branch_queue.popFront().?;
        current_odd_root = info.v0;
        curr_dist = info.v1;
        var last_is_leaf = true;
        var last_key: usize = 0;
        const doubling_list = tree.get(current_odd_root).?.items;
        for (doubling_list, 0..) |i, count| {
            if (i != 4 and edges.contains(i)) {
                try branch_queue.pushBack(allocator, .{ .v0 = edges.get(i).?, .v1 = curr_dist + 1 });
                if (count == doubling_list.len - 1) {
                    last_is_leaf = false;
                }
            }
            last_key = i;
            max_dist = @max(max_dist, curr_dist);
            curr_dist += 1;
        }
        if (last_is_leaf) {
            std.debug.print("{} (depth {})\r", .{ last_key, curr_dist - 1 });
        }
        run = branch_queue.len > 0;
    }
    std.debug.print("\nmax depth: {}\n", .{max_dist});
}

test "number of branches" {
    const allocator = std.testing.allocator;
    for (1..6 + 1) |i| {
        const upper_bound = try std.math.powi(usize, 10, i);
        var edges = collatz_tree.Edges.empty;
        defer {
            edges.deinit(allocator);
        }
        var tree = collatz_tree.Tree.init(allocator);
        defer {
            var tree_values_it = tree.valueIterator();
            while (tree_values_it.next()) |val| {
                val.deinit(allocator);
            }
            tree.deinit();
        }
        try collatz_tree.generateCollatzBranches(allocator, &tree, upper_bound);
        try collatz_tree.buildCollatzSubtreeEdges(allocator, &edges, tree);
        std.debug.print("N={}, |branches|={}\n", .{ upper_bound, edges.items.len });
    }
}
