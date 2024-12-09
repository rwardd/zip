.global rv32_exception_handler
rv32_exception_handler:
    call save_context
    csrr a0, mcause
    csrr a1, mepc
    addi a1, a1, 4
    sw a1, 4(x17)
    lw sp, isr_sp
    call context_switch
