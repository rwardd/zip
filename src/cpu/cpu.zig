const sched = @import("../sched/sched.zig");
const task = @import("../task/task.zig");

// Arch specific cpu here
const arch = @import("arch");

pub const tcb = arch.tcb;

pub fn exec_first_task(current: *tcb) void {
    arch.exec_first_task(current);
}

inline fn save_context() void {
    arch.save_context();
}

inline fn restore_context(curr_tcb: *tcb) void {
    arch.restore_context(curr_tcb);
}

pub inline fn yield() void {
    arch.yield();
}

export fn context_switch() void {
    sched.switch_tasks();
    //restore_context(&tasks.new.?.control);
}
