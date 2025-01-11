//! Zip entrypoint
//!
//! This file shows an example usage of the Zip scheduler, by defining 3 tasks and their respective
//! stacks. The scheduler is then run, and the tasks are run.

/// Module imports
const task = @import("task/task.zig");
const sched = @import("sched/sched.zig");
const logger = @import("log.zig");

/// @brief  Thread 1
/// @param  args: A pointer to an argument structure
/// @retval none
fn hello1(args: ?*anyopaque) void {
    _ = args;
    var cnt: u32 = 1;
    while (true) {
        logger.log("Hello from task 1 ");
        log_number(cnt);
        cnt = (cnt + 1) % 0x70; // loop back round without overflowing u8
        sched.yield();
    }
}

/// @brief  Thread 2
/// @param  args: A pointer to an argument structure
/// @retval none
fn hello2(args: ?*anyopaque) void {
    _ = args;
    while (true) {
        logger.log("Hello from task 2\n");
        sched.yield();
    }
}

/// @brief  Thread 3
/// @param  args: A pointer to an argument structure
/// @retval none
fn hello3(args: ?*anyopaque) void {
    _ = args;
    while (true) {
        logger.log("Hello from task 3\n");
        sched.yield();
    }
}

/// @brief  Helper funtion to essentially itoa() an 8 bit int and print
/// @param  x: The number to print
/// @retval none
fn log_number(x: u32) void {
    // Obviously bad and will need to fix
    const conv: u8 = @intCast(x & 0xff);
    const num = [_]u8{conv + 0x30};
    logger.log(&num);
    logger.log("\n");
}

var thread1_stack = task.create_stack(256); //[_]u8{0} ** 256;
var thread2_stack = task.create_stack(256); //[_]u8{0} ** 256;
var thread3_stack = task.create_stack(256); //[_]u8{0} ** 256;

/// Entrypoint, should never return
export fn start() noreturn {
    // Not sure if there is a better way to do this
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
    sched.run();

    // Compiler happy time
    while (true) {}
}
