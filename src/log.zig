const arch = @import("arch");

pub fn log(msg: []const u8) void {
    const uart_buf_reg: *u8 = @ptrFromInt(arch.UART_BUF_REG_ADDR);
    for (msg) |b| {
        uart_buf_reg.* = b;
    }
}
