const nvic_interrupt_control_reg: *volatile u32 = @ptrFromInt(0xe000ed04);
const pendsv_bit: usize = 1 << 28;

pub const tcb = packed struct {
    sp: usize = 0,
    ra: usize = 0,
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
        \\ dsb 
        ::: "memory");
    asm volatile (
        \\ isb
    );
}

export fn pend_sv_handler() void {
    asm volatile (
        \\ .extern current_tcb
        \\ .syntax unified
        \\ mrs r0, psp
        \\ ldr r2, =current_tcb
        \\ ldr r1, [r2]
        \\ subs r0, r0, #36
        \\ str r0, [r1]
        \\ mov r3, lr
        \\ stmia r0!, {r3-r7}
        \\ mov r4, r8
        \\ mov r5, r9
        \\ mov r6, r10
        \\ mov r7, r11
        \\ stmia r0!, {r4-r7}
        \\ cpsid i
        \\ bl context_switch
        \\ .align 4
    );
}

pub fn exec_first_task(current: *tcb) void {
    asm volatile (
        \\ ldr r1, [r0]
        \\ ldr r2, [r0, #4] 
        \\ movs r1, #2
        \\ msr CONTROL, r1
        \\ msr psp, r0
        \\ cpsie i
        \\ dsb
        \\ isb
        \\ bx r2
        \\ .align 4
        :
        : [curr] "r" (current),
        : "memory"
    );
}

//pub fn exec_first_task(current: *tcb) void {
//    asm volatile (
//        \\ ldr r1, [r0]
//        \\ ldm r1!, {r3}
//        \\ movs r2, #2
//        \\ msr CONTROL, r2
//        \\ adds r1, #32
//        \\ msr psp, r1
//        \\ isb
//        \\ bx r3
//        \\ .align 4
//        :
//        : [curr] "r" (current),
//        : "memory"
//    );
//}

pub inline fn restore_context(curr_tcb: *tcb) void {
    asm volatile (
        \\ .syntax unified
        \\ ldr r1, [r0]
        \\ adds r1, r1, #20
        \\ ldmia r1!, {r4-r7}
        \\ mov r8, r4
        \\ mov r9, r5
        \\ mov r10, r6
        \\ mov r11, r7
        \\ msr psp, r1
        \\ subs r1, r1, #36
        \\ ldmia r1!, {r3-r7}
        \\ cpsie i
        \\ bx r3
        \\ .align 4
        :
        : [curr] "r" (curr_tcb),
        : "memory"
    );
}
