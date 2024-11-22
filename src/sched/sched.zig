// Pre-emptive thread scheduler
const task = @import("../task/task.zig");

pub fn idle_tick(args: ?*anyopaque) void {
    _ = args;
    while (true) {
        yield();
    }
}

pub fn yield() void {}
pub fn run() void {}

const scheduler = struct {
    const t = task.current_task;
};
