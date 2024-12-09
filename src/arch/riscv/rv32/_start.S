.section .init

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
    li t1, 0x800
    csrw mie, t1
    li t1, 0x8
    csrw mstatus, t1
    tail    start

/* Loop */
wait_interrupt:
    wfi
    j wait_interrupt 

