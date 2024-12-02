const sched = @import("../../../sched/sched.zig");
const task = @import("../../../task/task.zig");

const word_size = 4;

fn save_context(curr_tcb: *task.tcb, regs: usize) void {
    asm volatile (
        \\ sw s1,   0(%[regs])
        \\ sw s2,   4(%[regs])
        \\ sw s3,   8(%[regs])
        \\ sw s4,   12(%[regs])
        \\ sw s5,   16(%[regs])
        \\ sw s6,   24(%[regs])
        \\ sw s7,   28(%[regs])
        \\ sw s8,   32(%[regs])
        \\ sw s9,   36(%[regs])
        \\ sw s10,  40(%[regs])
        \\ sw s11,  44(%[regs])
        \\ sw sp,   0(%[curr_tcb])
        :
        : [curr_tcb] "{x17}" (curr_tcb),
          [regs] "{x16}" (regs),
        : "memory"
    );
}

fn restore_context(curr_tcb: *task.tcb, regs: usize) void {
    asm volatile (
        \\ lw sp,   0(%[curr_tcb])
        \\ lw ra,   4(%[curr_tcb])
        \\ lw s1,   0(%[regs])
        \\ lw s2,   4(%[regs])
        \\ lw s3,   8(%[regs])
        \\ lw s4,   12(%[regs])
        \\ lw s5,   16(%[regs])
        \\ lw s6,   24(%[regs])
        \\ lw s7,   28(%[regs])
        \\ lw s8,   32(%[regs])
        \\ lw s9,   36(%[regs])
        \\ lw s10,  40(%[regs])
        \\ lw s11,  44(%[regs])
        \\ ret
        :
        : [curr_tcb] "{x17}" (curr_tcb),
          [regs] "{x16}" (regs),
        : "memory"
    );
}

pub fn context_switch() void {
    // perform ctx switch here
    save_context(&task.current_task.?.control, task.current_task.?.control.regs);
    sched.switch_tasks();
    restore_context(&task.current_task.?.control, task.current_task.?.control.regs);
}
