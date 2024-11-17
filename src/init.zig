const thread = @import("thread/tcb.zig");
const UART_BUF_REG_ADDR: usize = 0x10000000;

fn log(msg: []const u8) void {
    const uart_buf_reg: *u8 = @ptrFromInt(UART_BUF_REG_ADDR);
    for (msg) |b| {
        uart_buf_reg.* = b;
    }
}

export fn start() noreturn {
    var new_tcb: thread.tcb = undefined;
    new_tcb.id = 2;
    new_tcb.priority = 1;
    thread.thread_create(&new_tcb);

    const x: u32 = thread.get_task_id();
    const p1: u8 = @intCast(x & 0xff);
    const p2: u8 = @intCast((x >> 8) & 0xff);
    const p3: u8 = @intCast((x >> 16) & 0xff);
    const p4: u8 = @intCast((x >> 24) & 0xff);
    const y: [4]u8 = .{ 65 + p1, 65 + p2, 65 + p3, 65 + p4 };
    log(&y);
    log("Hello world\n");
    while (true) {}
}
