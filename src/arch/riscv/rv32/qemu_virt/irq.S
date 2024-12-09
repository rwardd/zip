.global rv32_exception_handler
.extern current_tcb

.macro save_context
	lw x17,  current_tcb
	sw sp,   0(x17)
	sw ra,   4(x17)
	sw s0,   8(x17)
	sw s1,   12(x17)
	sw s2,   16(x17)
	sw s3,   20(x17)
	sw s4,   24(x17)
	sw s5,   28(x17)
	sw s6,   32(x17)
	sw s7,   36(x17)
	sw s8,   40(x17)
	sw s9,   44(x17)
	sw s10,  48(x17)
.endm


rv32_exception_handler:
    save_context
    csrr a0, mcause
    csrr a1, mepc
    addi a1, a1, 4
    sw a1, 4(x17)
    lw sp, isr_sp
    call context_switch
