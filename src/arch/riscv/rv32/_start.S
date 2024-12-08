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
    csrw mtvec, t0
    li t1, 0x800
    csrw mie, t1
    li t1, 0x8
    csrw mstatus, t1
    //csrr t0, mstatus
    //andi t0, t0, ~0x8 
    //addi t1, x0, 0x188 
    //slli t1, t1, 4
    //or t0, t0, t1 
    //addi x5, t0, 0x08
    //csrrw x0, mstatus, x5 
    tail    start

/* Loop */
wait_interrupt:
    wfi
    j wait_interrupt 

