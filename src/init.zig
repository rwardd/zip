const task = @import("task/task.zig");
const sched = @import("sched/sched.zig");
const logger = @import("log.zig");

fn hello1(args: ?*anyopaque) void {
    _ = args;
    while (true) {
        logger.log("Hello from task 1\n");
        sched.yield();
    }
}

fn hello2(args: ?*anyopaque) void {
    _ = args;
    while (true) {
        logger.log("Hello from task 2\n");
        sched.yield();
    }
}

fn hello3(args: ?*anyopaque) void {
    _ = args;
    while (true) {
        logger.log("Hello from task 3\n");
        sched.yield();
    }
}

fn log_number(x: u32) void {
    // Obviously bad and will need to fix
    const conv: u8 = @intCast(x & 0xff);
    const num = [_]u8{conv + 0x30};
    logger.log(&num);
    logger.log("\n");
}

export fn start() noreturn {
    // BIG TODO: Look at a better way to store task structures
    // Not a fan of just keeping them here on the start stack
    // Should be defined in memory region ???
    var thread1_id = task.thread_create_handle();
    var thread2_id = task.thread_create_handle();
    var thread3_id = task.thread_create_handle();

    task.thread_create(&thread1_id, &hello1, 1, 3);
    task.thread_create(&thread2_id, &hello2, 2, 2);
    task.thread_create(&thread3_id, &hello3, 3, 1);

    log_number(task.get_thread_tcb(1).?.priority);
    log_number(task.get_thread_tcb(2).?.priority);
    log_number(task.get_thread_tcb(3).?.priority);

    logger.log("Hello world\n");
    while (true) {}
}
