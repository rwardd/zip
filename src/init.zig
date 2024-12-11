const task = @import("task/task.zig");
const sched = @import("sched/sched.zig");
const logger = @import("log.zig");
fn hello1(args: ?*anyopaque) void {
    var cnt: u32 = 1;
    while (true) {
        logger.log("Hello from task 1 ");
        log_number(cnt);
        cnt = (cnt + 1) % 0x70; // loop back round without overflowing u8
        sched.yield();
    }
    _ = args;
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

// Maybe look at some kind of dynamic allocation
var thread1_stack = task.create_stack(256); //[_]u8{0} ** 256;
var thread2_stack = task.create_stack(256); //[_]u8{0} ** 256;
var thread3_stack = task.create_stack(256); //[_]u8{0} ** 256;
var isr_stack = task.create_stack(256);
export var isr_sp: usize = 0;

export fn test_irq() void {
    logger.log("hello from irq\n");
}

export fn rv32_eh() void {
    logger.log("hello from eh\n");
}

export fn rv32_isr() void {
    logger.log("hello from irq\n");
}

fn test_seg(shit_value: usize) void {
    asm volatile (
        \\ lw x11, 0(%[shit_value])
        :
        : [shit_value] "{x10}" (shit_value),
    );
}
export fn start() noreturn {
    // Not sure if there is a better way to do this
    isr_sp = @intFromPtr(&isr_stack) + isr_stack.len;
    var thread1 = task.create(&hello1, 3, &thread1_stack);
    var thread2 = task.create(&hello2, 2, &thread2_stack);
    var thread3 = task.create(&hello3, 1, &thread3_stack);

    task.init(&thread1);
    task.init(&thread2);
    task.init(&thread3);

    log_number(task.get_thread_tcb(0).?.priority);
    log_number(task.get_thread_tcb(1).?.priority);
    log_number(task.get_thread_tcb(2).?.priority);

    logger.log("Hello world\n");
    test_seg(0);
    sched.run();
    while (true) {}
}
