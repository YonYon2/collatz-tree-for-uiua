const std = @import("std");
const collatz_tree = @import("collatz_tree_for_uiua");

pub fn main(init: std.process.Init) !void {
    // Prints to stderr, unbuffered, ignoring potential errors.
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    // upper bound N
    const upper_bound: usize = 10;
    const allocator = init.arena.allocator();
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
    std.debug.print("cap: {}\n", .{tree.capacity()});
    var tree_it = tree.iterator();
    while (tree_it.next()) |entry| {
        std.debug.print("{}", .{entry.value_ptr.items[0]});
        for (entry.value_ptr.items[1..]) |i| {
            std.debug.print("-{}", .{i});
        }
        std.debug.print("\n", .{});
    }
    // if it runs, a graph of the collatz tree should be able to be displayed using edges
    try collatz_tree.buildCollatzSubtreeEdges(allocator, &edges, tree);

    // std.debug.print("|K| = {}, |V| = {}\ndone!\n", .{ edges.keyIterator().len, edges.valueIterator().len });
    // depth first search to display edges length-wise (longer = deeper)
    var branch_queue = std.ArrayList(usize).empty;
    defer branch_queue.deinit(allocator);
    // load up queue
    // var current = 1;
    for (edges.items) |e| {
        std.debug.print("({}, {}) ", .{ e.v0, e.v1 });
    }
}
