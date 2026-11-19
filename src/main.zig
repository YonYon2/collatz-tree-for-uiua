const std = @import("std");
const collatz_tree = @import("collatz_tree_for_uiua");

pub fn main(init: std.process.Init) !void {
    // Prints to stderr, unbuffered, ignoring potential errors.
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    // upper bound N
    const upper_bound = 100;
    const allocator = init.arena.allocator();
    var edges = try collatz_tree.Edges.initCapacity(allocator, upper_bound);
    defer edges.deinit(allocator);
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
    // if it runs, a graph of the collatz tree should be able to be displayed using edges
    try collatz_tree.buildCollatzSubtreeEdges(allocator, &edges, tree);
    std.debug.print("done!\n", .{});
}
