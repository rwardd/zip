#define word_size 4
.extern current_tcb
.macro save_context
    addi sp, sp, -60
    sw x1,   1 * word_size(sp)
    sw x5,   2 * word_size(sp)
    sw x6,   3 * word_size(sp)
    sw x7,   4 * word_size(sp)
    sw x8,   5 * word_size(sp)
    sw x9,   6 * word_size(sp)
    sw x10,  7 * word_size(sp)
    sw x11,  8 * word_size(sp)
    sw x12,  9 * word_size(sp)
    sw x13, 10 * word_size(sp)
    sw x14, 11 * word_size(sp)
    sw x15, 12 * word_size(sp)

    lw t0, current_tcb
    sw sp, 0(t0)

.macro restore_context
    lw t1, current_tcb
    lw sp, 0(t1)

