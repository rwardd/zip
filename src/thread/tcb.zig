const logger = @import("../log.zig");

const tcb = struct {
    id: u32 = 0,
    priority: u32 = 0,
    next: ?*tcb = null,
};

// TODO: properly implement this
var head_tcb: ?*tcb = null;
var current_tcb: ?*tcb = null;

/// More stuff to go in here:
///     - tick fn
///     - stack addr
pub const thread_handle = struct {
    control: tcb,
};

pub fn get_task_id() u32 {
    return current_tcb.?.id;
}

pub fn get_task_priority() u32 {
    return current_tcb.?.priority;
}

pub fn get_first_task_prio() u32 {
    return head_tcb.?.priority;
}

pub fn thread_create_handle() thread_handle {
    return thread_handle{ .control = tcb{} };
}

pub fn thread_create(handle: *thread_handle, id: u32, priority: u32) void {
    handle.control.priority = priority;
    handle.control.id = id;

    if (current_tcb) |current| {
        current.next = &handle.control;
        current_tcb = &handle.control;
    } else {
        current_tcb = &handle.control;
        head_tcb = current_tcb;
    }
}
