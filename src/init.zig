const thread = @import("thread/tcb.zig");
const logger = @import("log.zig");

export fn start() noreturn {
    var thread1_id = thread.thread_create_handle();
    var thread2_id = thread.thread_create_handle();
    var thread3_id = thread.thread_create_handle();

    thread.thread_create(&thread1_id, 1, 2);
    thread.thread_create(&thread2_id, 2, 3);

    const x: u32 = thread.get_first_task_prio();
    const p1: u8 = @intCast(x & 0xff);
    const p2: u8 = @intCast((x >> 8) & 0xff);
    const p3: u8 = @intCast((x >> 16) & 0xff);
    const p4: u8 = @intCast((x >> 24) & 0xff);
    const y: [4]u8 = .{ 65 + p1, 65 + p2, 65 + p3, 65 + p4 };

    thread.thread_create(&thread3_id, 3, 1);
    const x1: u32 = thread.get_task_priority();
    const p11: u8 = @intCast(x1 & 0xff);
    const p21: u8 = @intCast((x1 >> 8) & 0xff);
    const p31: u8 = @intCast((x1 >> 16) & 0xff);
    const p41: u8 = @intCast((x1 >> 24) & 0xff);
    const y1: [4]u8 = .{ 65 + p11, 65 + p21, 65 + p31, 65 + p41 };

    logger.log(&y);
    logger.log("\n");
    logger.log(&y1);
    logger.log("\n");
    logger.log("Hello world\n");
    while (true) {}
}
