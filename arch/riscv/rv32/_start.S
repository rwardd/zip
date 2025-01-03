.section .text

.global _start
_start:
    la      sp, _stack_top
    la      a1, _bss_start
    la      a2, _bss_end

clear_bss:
    sw      zero, (a2)
    addi    a1, a1, 4
    bltu    a1, a2, clear_bss

entrypoint:
    la t0, zvt

	// Shift this to run_sched
    csrw mtvec, t0
    li t1, 0x08
    csrw mstatus, t1
    call start

/* Loop */
wait_interrupt:
    wfi
    j wait_interrupt 

