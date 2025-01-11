//! System scheduler
//!
//! Currently a very simple round robin cooperative scheduler.

/// Module imports
const task = @import("../task/task.zig");
const logger = @import("../log.zig");
const cpu = @import("../cpu/cpu.zig");

/// Create a stack for the interrupt service routines to use, so we don't clobber task stacks
var isr_stack = task.create_stack(256);
export var isr_sp: usize = 0;

/// A pointer to the current task's control block
export var current_tcb: ?*volatile cpu.tcb = null;

/// @brief Idle tick. Need to implement
fn idle_tick(args: ?*anyopaque) void {
    _ = args;
    while (true) {
        logger.log("Hello from idle task\n");
        yield();
    }
}

/// @brief The core context switcher. Really need to improve.
pub fn switch_tasks() void {
    const old_head = task.head_task;
    task.head_task = task.head_task.?.next;
    var tmp: ?*task.task_handle = task.head_task;

    while (tmp) |node| {
        if (node.next == null) {
            break;
        }
        tmp = node.next;
    }

    old_head.?.next = null;
    tmp.?.next = old_head;
    task.current_task = task.head_task;
    current_tcb = &task.current_task.?.control;
}

/// @brief Yield the current task
pub inline fn yield() void {
    current_tcb = &task.current_task.?.control;
    cpu.yield();
}

/// @brief create the idle task, and add it to the end of the task queue.
fn create_idle_task(stack: []usize) task.task_handle {
    return task.task_create(&idle_tick, 32, stack);
}

/// Main entrypoint, should not return.
pub fn run() void {
    isr_sp = @intFromPtr(&isr_stack) + isr_stack.len;
    task.current_task = task.head_task;
    cpu.exec_first_task(&task.current_task.?.control);
}

/// Move to an error handler
export fn hardfault_handler() noreturn {
    // Loop here
    while (true) {}
}
