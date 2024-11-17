const UART_BUF_REG_ADDR: usize = 0x10000000;

pub fn log(msg: []const u8) void {
    const uart_buf_reg: *u8 = @ptrFromInt(UART_BUF_REG_ADDR);
    for (msg) |b| {
        uart_buf_reg.* = b;
    }
}
