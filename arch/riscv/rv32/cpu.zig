const word_size = 4;

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

pub inline fn yield() void {
    asm volatile (
        \\ ecall
    );
}

pub inline fn save_context() void {}

pub fn exec_first_task(current: *tcb) void {
    asm volatile (
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
        : [new_tcb] "{x17}" (current),
        : "memory"
    );
}

pub inline fn restore_context(curr_tcb: *tcb) void {
    asm volatile (
        \\ lw sp,   0(%[curr_tcb])
        \\ lw t0,   4(%[curr_tcb])
        \\ csrw mepc, t0 
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
        \\ mret
        :
        : [curr_tcb] "{x17}" (curr_tcb),
        : "memory"
    );
}
