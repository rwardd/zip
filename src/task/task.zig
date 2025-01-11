//! System task structure
//!
//! For now, each task consists of a task handle, which houses the TCB, tick function, and a pointer
//! to the next task to run. This will get cleaned up, but it's much easier to debug this way.
//!
//! The tasks are initialised into a linked list, in order of creation.

/// Module imports
const logger = @import("../log.zig");
const cpu = @import("../cpu/cpu.zig");

pub const tcb = cpu.tcb;

/// Thread entrypoint function pointer typedef
pub const tick_fn = *const fn (args: ?*anyopaque) void;

/// Current task handle
pub var current_task: ?*task_handle = null;

/// Head task handle
pub var head_task: ?*task_handle = null;

/// @brief  Task handle structure.
///
/// @note   Needs to be fleshed out more, and stripped back, as many things are handled in the tcb
///         rather than the task_handle.
pub const task_handle = struct {
    const Self = @This();
    control: tcb,
    tick: ?tick_fn = null,
    next: ?*task_handle = null,
    stack: []u32,

    pub fn get_tcb(self: *Self) ?*tcb {
        return &self.control;
    }
};

/// @brief  Create an empty task handle
/// @retval none
pub fn thread_create_handle() task_handle {
    return task_handle{
        .control = tcb{},
    };
}

/// @brief  Get a task's control block
/// @TODO:  Implement some error handling!
///
/// @param  The task id
pub fn get_thread_tcb(id: u32) ?*tcb {
    var current: ?*task_handle = head_task;
    while (current) |node| : (current = node.next) {
        if (node.control.id == id) {
            return node.get_tcb();
        }
    }

    return &current.?.control;
}

/// @brief  Initialise a task
///         This process involves adding it to the linked list of tasks to run and configuring the
///         task's stack.
///
/// @param  The task handle to initialise
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

    const stack_top = cpu.initialise_stack(handle.stack, @intFromPtr(handle.tick));
    handle.control.id = id;
    handle.control.sp = stack_top;
    handle.control.ra = @intFromPtr(handle.tick);
}

/// @brief  Helper function to create a stack of length stack_size
/// @param  stack_size: The size of the stack to create
/// @retval The stack slice
pub fn create_stack(comptime stack_size: u32) [stack_size]u32 {
    return [_]u32{0} ** stack_size;
}

/// Creates a new task handle
/// @param tick: The task's tick fn
/// @param priority: The task's priority
/// @param stack: The task's stack pointer
pub fn create(tick: tick_fn, priority: u32, stack: []u32) task_handle {
    return task_handle{
        .control = tcb{
            .priority = priority,
            .sp = 0,
        },
        .tick = tick,
        .stack = stack,
    };
}
