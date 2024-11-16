const std = @import("std");

pub const tcb = struct {
    id: u32,
    priority: u32,
};

var tcb_ll: std.SinglyLinkedList(*tcb) = undefined;

pub fn get_task_id() u32 {
    return tcb_ll.first.?.data.id;
}

pub fn thread_create(tcb_buffer: *tcb) void {
    var tcb_node: std.SinglyLinkedList(*tcb).Node = .{ .data = tcb_buffer };
    tcb_ll.prepend(&tcb_node);
}
