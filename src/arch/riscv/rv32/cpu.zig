const sched = @import("../../../sched/sched.zig");
const task = @import("../../../task/task.zig");

const word_size = 4;

fn save_context() void {
    asm volatile (
        \\ addi sp, sp, -60
        \\ sw x1,   4(sp)
        \\ sw x5,   8(sp)
        \\ sw x6,   12(sp)
        \\ sw x7,   16(sp)
        \\ sw x8,   24(sp)
        \\ sw x9,   28(sp)
        \\ sw x10,  32(sp)
        \\ sw x11,  36(sp)
        \\ sw x12,  40(sp)
        \\ sw x13,  44(sp)
        \\ sw x14,  48(sp)
        \\ sw x15,  52(sp)
        \\ lw t0, current_tcb
        \\ sw sp, 0(t0)
        \\ csrr a0, mcause
        \\ csrr a1, mepc
        \\ sw a1, 0 (sp)
    );
}

fn restore_context() void {
    asm volatile (
        \\ lw t1, current_tcb
        \\ lw sp, 0(t1)
        \\ lw t0, 0 (sp)
    );
}

pub fn context_switch() void {
    // perform ctx switch here
    save_context();
    sched.switch_tasks();
}
