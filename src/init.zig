const thread = @import("thread/tcb.zig");
const UART_BUF_REG_ADDR: usize = 0x10000000;

fn log(comptime msg: []const u8) void {
    const uart_buf_reg: *u8 = @ptrFromInt(UART_BUF_REG_ADDR);
    for (msg) |b| {
        uart_buf_reg.* = b;
    }
}

export fn start() noreturn {
    var new_tcb: thread.tcb = undefined;
    thread.thread_create(1, 2, &new_tcb);
    log("Hello world\n");
    while (true) {}
}
