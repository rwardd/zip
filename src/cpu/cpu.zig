//! Interface to CPU architecture.
//!
//! Different architectures require different methods of stack initialisation, yielding and
//! context switching.

/// Module imports
const sched = @import("../sched/sched.zig");
const task = @import("../task/task.zig");
const arch = @import("arch");

// TCB structure
pub const tcb = arch.tcb;

/// @brief  Executes the first task to run.
/// @param  current: The first task context to run
pub fn exec_first_task(current: *tcb) void {
    arch.exec_first_task(current);
}

/// @brief  Saves the current task context (largely unused)
/// @retval none
inline fn save_context() void {
    arch.save_context();
}

/// @brief  Initialised the task stack
/// @param  stack: A slice of contiguous memory
/// @param  tick:  The tick function to be loaded onto the task stack
/// @retval stack_ptr: A new pointer to the top of the stack
pub fn initialise_stack(stack: []u32, tick: usize) usize {
    return arch.initialise_stack(stack, tick);
}

/// @brief  Restore a task's context (largely unused)
/// @param  current: The current task context to restore
/// @retval none
inline fn restore_context(current: *tcb) void {
    arch.restore_context(current);
}

/// @brief  Yield the current process to the OS.
/// @retval none
pub inline fn yield() void {
    arch.yield();
}

/// @brief  Perform a context switch, saving the context of the old task, and loading the context
///         of the new task
/// @retval none
export fn context_switch() void {
    sched.switch_tasks();
}
