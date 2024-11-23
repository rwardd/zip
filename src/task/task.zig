const logger = @import("../log.zig");
const std = @import("std");

// TODO: properly implement this
pub const thread_fn = *const fn (args: ?*anyopaque) void;

pub var idle_task: task_handle = task_handle{
    .control = tcb{ .id = 0, .priority = 32, .sp = 0 },
    .tick = @import("../sched/sched.zig").idle_tick,
    .next = null,
};

var current_task: *task_handle = &idle_task;

/// More stuff to go in here:
///     - tick fn
///     - stack addr
pub const task_handle = struct {
    const Self = @This();
    control: tcb,
    tick: ?thread_fn = null,
    next: ?*task_handle = null,

    pub fn get_tcb(self: *Self) ?*tcb {
        return &self.control;
    }
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
    var current: ?*task_handle = &idle_task;
    while (current) |node| : (current = node.next) {
        if (node.control.id == id) {
            return node.get_tcb();
        }
    }

    return &current.?.control;
}

pub fn thread_create(handle: *task_handle, tick_fn: thread_fn, priority: u32) void {
    handle.control.priority = priority;
    handle.control.id = current_task.control.id + 1;
    handle.tick = tick_fn;

    current_task.next = handle;
    current_task = handle;
}
