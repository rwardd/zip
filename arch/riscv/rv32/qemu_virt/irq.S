.global rv32_exception_handler
.global rv32_isr

.extern current_tcb
.extern isr_sp
.extern context_switch

.macro save_context
    addi sp, sp, -52
	sw x1,   4(sp)
	sw x5,   8(sp)
	sw x6,   12(sp)
	sw x7,   16(sp)
	sw x8,   20(sp)
	sw x9,   24(sp)
	sw x10,  28(sp)
	sw x11,  32(sp)
	sw x12,  36(sp)
	sw x13,  40(sp)
	sw x14,  44(sp)
	sw x15,  48(sp)
	lw t0,  current_tcb
    sw sp, 0(t0)
.endm


rv32_exception_handler:
    csrr a0, mcause
    li t0, 11
    bne a0, t0, exception
    save_context
    csrr a1, mepc
    addi a1, a1, 4
    sw a1, 0(sp)
    lw sp, isr_sp
    call context_switch
    lw t1,   current_tcb
    lw sp,   0(t1)
    lw t0,   0(sp)
    csrw mepc, t0 
    lw x1,   4(sp) 
    lw x5,   8(sp)
    lw x6,   12(sp)
    lw x7,   16(sp)
    lw x8,   20(sp)
    lw x9,   24(sp)
    lw x10,  28(sp)
    lw x11,  32(sp)
    lw x12,  36(sp)
    lw x13,  40(sp)
    lw x14,  44(sp)
    lw x15,  48(sp)
    addi sp, sp, 52
    mret     



exception:
	li t0, 5 /* hard fault */
	beq a0, t0, hardfault_handler

rv32_isr:
    j rv32_isr

