const UART_BUF_REG_ADDR: usize = 0x10000000;
const UART_LSR: usize = 0x10000000 + 0x0005;

pub fn log(msg: []const u8) void {
    const uart_buf_reg: *volatile u32 = @ptrFromInt(UART_BUF_REG_ADDR);
    const uart_lsr: *volatile u8 = @ptrFromInt(UART_LSR);
    for (msg) |b| {
        while ((uart_lsr.* & 0x60) == 0) {}
        if (b == 0x0D) {
            uart_buf_reg.* = 0x0A;
        } else {
            uart_buf_reg.* = b;
        }
    }
}
