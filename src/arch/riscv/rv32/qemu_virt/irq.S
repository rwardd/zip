.global rv32_exception_handler
.extern current_tcb
.extern isr_sp

.macro save_context
	lw t0,  current_tcb
	sw sp,   0(t0)
	sw x1,   4(t0)
	sw x5,   8(t0)
	sw x6,   12(t0)
	sw x7,   16(t0)
	sw x8,   20(t0)
	sw x9,   24(t0)
	sw x10,  28(t0)
	sw x11,  32(t0)
	sw x12,  36(t0)
	sw x13,  40(t0)
	sw x14,  44(t0)
	sw x15,  48(t0)
.endm


rv32_exception_handler:
    csrr a0, mcause
	li t0, 11
	bne a0, t0, not_ecall
    save_context
    csrr a1, mepc
    addi a1, a1, 4
    sw a1, 4(x17)
    lw sp, isr_sp
    call context_switch

not_ecall:
	li t0, 5 /* hard fault */
	beq a0, t0, hardfault_handler
