const logger = @import("../log.zig");
const cpu = @import("../cpu/cpu.zig");
const std = @import("std");

pub const tcb = cpu.tcb;
pub const thread_fn = *const fn (args: ?*anyopaque) void;
pub var current_task: ?*task_handle = null;
pub var head_task: ?*task_handle = null;
pub var tail_task: ?*task_handle = null;

pub const task_handle = struct {
    const Self = @This();
    control: tcb,
    tick: ?thread_fn = null,
    next: ?*task_handle = null,
    stack: []u32,

    pub fn get_tcb(self: *Self) ?*tcb {
        return &self.control;
    }
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

pub fn init(handle: *task_handle) void {
    var id: u32 = 0;
    if (current_task) |curr| {
        curr.next = handle;
        current_task = handle;
        id = curr.control.id + 1;
    } else {
        current_task = handle;
        head_task = handle;
    }
    var stack_top = handle.stack.len;
    handle.stack.ptr[stack_top - 1] = 0x1 << 24; // Program Status Register (xPSR)
    handle.stack.ptr[stack_top - 2] = @intFromPtr(handle.tick); // Program Counter (PC)
    handle.stack.ptr[stack_top - 3] = 0x14141414; // Link Register (LR)
    stack_top -= 17; // R0 .. R12
    handle.stack.ptr[stack_top] = 0xFFFFFFFD; // EXC_RETURN to thread mode

    handle.control.id = id;
    handle.control.sp = @intFromPtr(&handle.stack.ptr[stack_top]);
    handle.control.ra = @intFromPtr(handle.tick);
}

pub fn create_stack(comptime stack_size: u32) [stack_size]u32 {
    return [_]u32{0} ** stack_size;
}

pub fn create(tick_fn: thread_fn, priority: u32, stack: []u32) task_handle {
    return task_handle{
        .control = tcb{
            .priority = priority,
            .sp = 0,
        },
        .tick = tick_fn,
        .stack = stack,
    };
}
