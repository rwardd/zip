const task = @import("task/task.zig");
const sched = @import("sched/sched.zig");
const logger = @import("log.zig");

fn hello1(args: ?*anyopaque) void {
    const cnt: u32 = 1;
    while (true) {
        logger.log("Hello from task 1 ");
        log_number(cnt);
        sched.save_sp();
        sched.yield();
    }
    _ = args;
}

fn hello2(args: ?*anyopaque) void {
    _ = args;
    while (true) {
        logger.log("Hello from task 2\n");
        sched.save_sp();
        sched.yield();
    }
}

fn hello3(args: ?*anyopaque) void {
    _ = args;
    while (true) {
        logger.log("Hello from task 3\n");
        sched.save_sp();
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

    // Move this to specific linker section to avoid overflowing initial stack
    var thread1_stack = [_]u8{0} ** 256;
    var thread2_stack = [_]u8{0} ** 256;
    var thread3_stack = [_]u8{0} ** 256;

    var thread1 = task.task_create(&hello1, 3, &thread1_stack);
    var thread2 = task.task_create(&hello2, 2, &thread2_stack);
    var thread3 = task.task_create(&hello3, 1, &thread3_stack);

    task.task_init(&thread1);
    task.task_init(&thread2);
    task.task_init(&thread3);

    log_number(task.get_thread_tcb(0).?.priority);
    log_number(task.get_thread_tcb(1).?.priority);
    log_number(task.get_thread_tcb(2).?.priority);

    logger.log("Hello world\n");
    sched.run();
    while (true) {}
}
