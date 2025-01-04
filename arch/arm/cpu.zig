const nvic_interrupt_control_reg: *volatile u32 = @ptrFromInt(0xe000ed04);
const pendsv_bit: usize = 1 << 28;

pub const tcb = packed struct {
    psp: usize = 0,
    lr: usize = 0,
    r1: usize = 0,
    r2: usize = 0,
    r3: usize = 0,
    r4: usize = 0,
    r5: usize = 0,
    r6: usize = 0,
    r7: usize = 0,
    r8: usize = 0,
    r9: usize = 0,
    r10: usize = 0,
    r11: usize = 0,
    id: u32 = 0,
    priority: u32 = 0,
};

pub inline fn yield() void {
    nvic_interrupt_control_reg.* = pendsv_bit;
    asm volatile (
        \\ dsb ::: "memory"
    );

    asm volatile (
        \\ isb
    );
}

export fn PendSV_Handler() void {
    asm volatile (
        \\ .extern current_tcb
        \\ .syntax unified
        \\ mrs r0, psp
        \\ ldr r2, =current_tcb
        \\ ldr r1, [r2]
        \\ str r0, [r1]
        \\ subs r1, r1, #4
        \\ mov r3, lr
        \\ stmia r1!, {r3-r7}
        \\ mov r4, r8
        \\ mov r5, r9
        \\ mov r6, r10
        \\ mov r7, r11
        \\ cpsid i
        \\ bl context_switch
    );
}

// To do - convert to arm asm
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
