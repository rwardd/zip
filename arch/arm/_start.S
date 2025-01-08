.cpu cortex-m0
.thumb

.thumb_func
.global _start
_start:
    .word _stack_top
    .word _reset
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  0
    .word  pend_sv_handler
    .word  0
    .word  0
    .word  pend_sv_handler 
    .word  0 

.thumb_func
_reset:
    ldr r0, =_stack_top
    mov sp, r0

clear_bss:
    ldr r2, =_bss_start
    ldr r4, =_bss_end
    movs r3, #0
    b entrypoint 

fill_zeros:
    str r3, [r2]
    adds r2, r2, #4

entrypoint:
    cmp r2, r4
    bcc fill_zeros
    
    bl start

loop:
    b loop

default_handler:
    b loop
