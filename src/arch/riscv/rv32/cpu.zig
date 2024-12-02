const sched = @import("../../../sched/sched.zig");
const task = @import("../../../task/task.zig");

const word_size = 4;

fn switch_context(old_tcb: *task.tcb, new_tcb: *task.tcb) void {
    asm volatile (
        \\ sw sp,   0(%[old_tcb])
        \\ sw s0,   8(%[old_tcb])
        \\ sw s1,   12(%[old_tcb])
        \\ sw s2,   16(%[old_tcb])
        \\ sw s3,   20(%[old_tcb])
        \\ sw s4,   24(%[old_tcb])
        \\ sw s5,   28(%[old_tcb])
        \\ sw s6,   32(%[old_tcb])
        \\ sw s7,   36(%[old_tcb])
        \\ sw s8,   40(%[old_tcb])
        \\ sw s9,   44(%[old_tcb])
        \\ sw s10,  48(%[old_tcb])
        \\ lw sp,   0(%[new_tcb])
        \\ lw ra,   4(%[new_tcb])
        \\ lw s0,   8(%[new_tcb])
        \\ lw s1,   12(%[new_tcb])
        \\ lw s2,   16(%[new_tcb])
        \\ lw s3,   20(%[new_tcb])
        \\ lw s4,   24(%[new_tcb])
        \\ lw s5,   28(%[new_tcb])
        \\ lw s6,   32(%[new_tcb])
        \\ lw s7,   36(%[new_tcb])
        \\ lw s8,   40(%[new_tcb])
        \\ lw s9,   44(%[new_tcb])
        \\ lw s10,  48(%[new_tcb])
        \\ ret
        :
        : [old_tcb] "{a0}" (old_tcb),
          [new_tcb] "{a1}" (new_tcb),
        : "memory"
    );
}

fn restore_context(curr_tcb: *task.tcb) void {
    asm volatile (
        \\ lw sp,   0(%[curr_tcb])
        \\ lw ra,   4(%[curr_tcb])
        \\ lw s0,   8(%[curr_tcb])
        \\ lw s1,   12(%[curr_tcb])
        \\ lw s2,   16(%[curr_tcb])
        \\ lw s3,   24(%[curr_tcb])
        \\ lw s4,   28(%[curr_tcb])
        \\ lw s5,   32(%[curr_tcb])
        \\ lw s6,   36(%[curr_tcb])
        \\ lw s7,   40(%[curr_tcb])
        \\ lw s8,   44(%[curr_tcb])
        \\ lw s9,   48(%[curr_tcb])
        \\ lw s10,  52(%[curr_tcb])
        \\ ret
        :
        : [curr_tcb] "r" (curr_tcb),
        : "memory"
    );
}

pub fn context_switch() void {
    // perform ctx switch here
    const tasks = sched.switch_tasks();
    switch_context(&tasks.old.?.control, &tasks.new.?.control);
}
