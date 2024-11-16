const std = @import("std");

pub const tcb = struct {
    id: u32,
    priority: u32,
};

var tcb_ll: std.SinglyLinkedList(*tcb) = undefined;

pub fn thread_create(priority: u32, id: u32, tcb_buffer: *tcb) void {
    tcb_buffer.id = id;
    tcb_buffer.priority = priority;

    var tcb_node: std.SinglyLinkedList(*tcb).Node = .{ .data = tcb_buffer };
    tcb_ll.prepend(&tcb_node);
}
