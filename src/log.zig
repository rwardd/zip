//! Zip logger module
//!
//! Very simple at the moment, just fetches the board's UART data register, and writes to it.

const arch = @import("arch");

pub fn log(msg: []const u8) void {
    const uart_buf_reg: *u8 = @ptrFromInt(arch.UART_BUF_REG_ADDR);
    for (msg) |b| {
        uart_buf_reg.* = b;
    }
}
