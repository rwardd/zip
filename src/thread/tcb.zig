const std = @import("std");

pub const tcb = struct {
    id: u32,
};

const tcb_head = std.SinglyLinkedList(tcb);

pub fn thread_create(priority: u32) void {
    return priority;
}
