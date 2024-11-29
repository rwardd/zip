const sched = @import("../../../sched/sched.zig");
const task = @import("../../../task/task.zig");

const word_size = 4;

fn save_context(curr_tcb: *task.tcb) void {
    asm volatile (
        \\ sw sp,   0(%[curr_tcb])
        \\ sw s1,   8(%[curr_tcb])
        \\ sw s2,   12(%[curr_tcb])
        \\ sw s3,   16(%[curr_tcb])
        \\ sw s4,   24(%[curr_tcb])
        \\ sw s5,   28(%[curr_tcb])
        \\ sw s6,  32(%[curr_tcb])
        \\ sw s7,  36(%[curr_tcb])
        \\ sw s8,  40(%[curr_tcb])
        \\ sw s9,  44(%[curr_tcb])
        \\ sw s10,  48(%[curr_tcb])
        \\ sw s11,  52(%[curr_tcb])
        :
        : [curr_tcb] "r" (curr_tcb),
        : "memory"
    );
}

fn restore_context(curr_tcb: *task.tcb) void {
    asm volatile (
        \\ lw sp,   0(%[curr_tcb])
        \\ lw ra,   4(%[curr_tcb])
        \\ lw s1,   8(%[curr_tcb])
        \\ lw s2,   12(%[curr_tcb])
        \\ lw s3,   16(%[curr_tcb])
        \\ lw s4,   24(%[curr_tcb])
        \\ lw s5,   28(%[curr_tcb])
        \\ lw s6,  32(%[curr_tcb])
        \\ lw s7,  36(%[curr_tcb])
        \\ lw s8,  40(%[curr_tcb])
        \\ lw s9,  44(%[curr_tcb])
        \\ lw s10,  48(%[curr_tcb])
        \\ lw s11,  52(%[curr_tcb])
        \\ ret
        :
        : [curr_tcb] "r" (curr_tcb),
        : "memory"
    );
}

pub fn context_switch() void {
    // perform ctx switch here
    save_context(&task.current_task.?.control);
    sched.switch_tasks();
    restore_context(&task.current_task.?.control);
}
