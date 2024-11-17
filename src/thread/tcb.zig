const SinglyLinkedList = @import("std").SinglyLinkedList;

pub const tcb = struct {
    id: u32,
    priority: u32,
};

var tcb_ll: SinglyLinkedList(*tcb) = undefined;
var tcb_node: SinglyLinkedList(*tcb).Node = undefined;

pub fn get_task_id() u32 {
    return tcb_ll.first.?.data.id;
}

pub fn thread_create(tcb_buffer: *tcb) void {
    tcb_node = .{ .data = tcb_buffer };
    tcb_ll.prepend(&tcb_node);
}
