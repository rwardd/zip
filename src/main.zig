const SYSCON_REG_ADDR: usize = 0x11100000;
const UART_BUF_REG_ADDR: usize = 0x10000000;

const syscon: *u32 = @ptrFromInt(SYSCON_REG_ADDR);
const uart_buf_reg: *u8 = @ptrFromInt(UART_BUF_REG_ADDR);

export fn start() noreturn {
    for ("Hello world\n") |b| {
        // write each byte to the UART FIFO
        uart_buf_reg.* = b;
    }
    while (true) {}
}
