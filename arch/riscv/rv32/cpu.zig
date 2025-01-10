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

pub fn initialise_stack(stack: []u32, tick: usize) usize {
    const stack_top = stack.len;
    stack.ptr[stack_top - 16] = tick; // Top of stack is RA
    return @intFromPtr(&stack.ptr[stack_top - 16]);
}

pub inline fn yield() void {
    asm volatile (
        \\ ecall
    );
}

pub inline fn save_context() void {}

pub fn exec_first_task(current: *tcb) void {
    asm volatile (
        \\ lw sp,   0(%[new_tcb])
        \\ lw ra,   0(sp)
        \\ lw x5,   8(sp)
        \\ lw x6,   12(sp)
        \\ lw x7,   16(sp)
        \\ lw x8,   20(sp)
        \\ lw x9,   24(sp)
        \\ lw x10,  28(sp)
        \\ lw x11,  32(sp)
        \\ lw x12,  36(sp)
        \\ lw x13,  40(sp)
        \\ lw x14,  44(sp)
        \\ lw x15,  48(sp)
        \\ addi sp, sp, 52
        \\ ret
        :
        : [new_tcb] "{x17}" (current),
        : "memory"
    );
}

pub inline fn restore_context(curr_tcb: *tcb) void {
    asm volatile (
        \\ lw t0,   0(%[curr_tcb])
        \\ lw sp,   0(t1)
        \\ lw t0,   0(sp)
        \\ csrw mepc, t0 
        \\ lw x1,   4(sp) 
        \\ lw x5,   8(sp)
        \\ lw x6,   12(sp)
        \\ lw x7,   16(sp)
        \\ lw x8,   20(sp)
        \\ lw x9,   24(sp)
        \\ lw x10,  28(sp)
        \\ lw x11,  32(sp)
        \\ lw x12,  36(sp)
        \\ lw x13,  40(sp)
        \\ lw x14,  44(sp)
        \\ lw x15,  48(sp)
        \\ addi sp, sp, 52
        \\ mret     
        :
        : [curr_tcb] "{x17}" (curr_tcb),
        : "memory"
    );
}
