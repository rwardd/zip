const logger = @import("../log.zig");
const std = @import("std");

// TODO: properly implement this
pub const thread_fn = *const fn (args: ?*anyopaque) void;

pub var current_task: ?*task_handle = null;
pub var head_task: ?*task_handle = null;
pub var tail_task: ?*task_handle = null;
export var current_tcb: ?*tcb = null;

/// More stuff to go in here:
///     - tick fn
///     - stack addr
pub const task_handle = struct {
    const Self = @This();
    control: tcb,
    tick: ?thread_fn = null,
    next: ?*task_handle = null,
    stack: []u8,

    pub fn get_tcb(self: *Self) ?*tcb {
        return &self.control;
    }
};

pub const tcb = packed struct {
    sp: usize = 0,
    ra: usize = 0,
    s1: usize = 0,
    s2: usize = 0,
    s3: usize = 0,
    s4: usize = 0,
    s5: usize = 0,
    s6: usize = 0,
    s7: usize = 0,
    s8: usize = 0,
    s9: usize = 0,
    s10: usize = 0,
    s11: usize = 0,
    id: u32 = 0,
    priority: u32 = 0,
};

pub fn get_thread_id() u32 {
    return current_task.?.id;
}

pub fn get_thread_priority() u32 {
    return current_task.?.priority;
}

pub fn thread_create_handle() task_handle {
    return task_handle{
        .control = tcb{},
    };
}

pub fn get_thread_tcb(id: u32) ?*tcb {
    var current: ?*task_handle = head_task;
    while (current) |node| : (current = node.next) {
        if (node.control.id == id) {
            return node.get_tcb();
        }
    }

    return &current.?.control;
}

pub fn task_init(handle: *task_handle) void {
    var id: u32 = 0;
    if (current_task) |curr| {
        curr.next = handle;
        current_task = handle;
        id = curr.control.id + 1;
    } else {
        current_task = handle;
        head_task = handle;
    }
    handle.control.id = id;
    handle.control.sp = @intFromPtr(handle.stack.ptr) + handle.stack.len;
    handle.control.ra = @intFromPtr(handle.tick);
}

pub fn task_create(tick_fn: thread_fn, priority: u32, stack: []u8) task_handle {
    return task_handle{
        .control = tcb{
            .priority = priority,
            .sp = 0,
        },
        .tick = tick_fn,
        .stack = stack,
    };
}
