const UART_BUF_REG_ADDR: usize = 0x10000000;

fn log(comptime msg: []const u8) void {
    const uart_buf_reg: *u8 = @ptrFromInt(UART_BUF_REG_ADDR);
    for (msg) |b| {
        uart_buf_reg.* = b;
    }
}

export fn start() noreturn {
    log("Hello world\n");
    while (true) {}
}
