const logger = @import("../log.zig");
const std = @import("std");

// TODO: properly implement this
pub const thread_fn = *const fn (args: ?*anyopaque) void;

pub const idle_task: ?*task_handle = @constCast(&task_handle{
    .control = tcb{ .id = 1, .priority = 32, .sp = 0 },
    .tick = @import("../sched/sched.zig").idle_tick,
    .next = null,
});

pub var current_task: ?*task_handle = idle_task;

/// More stuff to go in here:
///     - tick fn
///     - stack addr
pub const task_handle = struct {
    control: tcb,
    tick: ?thread_fn = null,
    next: ?*task_handle = null,
};

const tcb = struct {
    id: u32 = 0,
    priority: u32 = 0,
    sp: usize = 0,
};

pub fn get_thread_id() u32 {
    return current_task.?.id;
}

pub fn get_thread_priority() u32 {
    return current_task.?.priority;
}

pub fn get_first_thread_prio() u32 {
    return idle_task.?.priority;
}

pub fn thread_create_handle() task_handle {
    return task_handle{
        .control = tcb{},
    };
}

pub fn get_thread_tcb(id: u32) ?*tcb {
    var current = idle_task;
    while (current) |node| : (current = node.next) {
        if (node.control.id == id) {
            return &current.?.control;
        }
    }

    return &current.?.control;
}

pub fn thread_create(handle: *task_handle, tick_fn: thread_fn, id: u32, priority: u32) void {
    handle.control.priority = priority;
    handle.control.id = id;
    handle.tick = tick_fn;

    if (current_task) |current| {
        current.next = handle;
        current_task = handle;
    } else {
        current_task = handle;
    }
}
