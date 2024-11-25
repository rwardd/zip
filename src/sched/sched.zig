// Pre-emptive thread scheduler
const task = @import("../task/task.zig");

// TODO: find a better way to do this
const cpu = @import("../arch/riscv/rv32/cpu.zig");

pub fn idle_tick(args: ?*anyopaque) void {
    _ = args;
    while (true) {
        yield();
    }
}

pub fn switch_tasks() void {
    const next_task = task.current_task.?.next;
    var tmp: ?*task.task_handle = task.current_task;
    while (tmp) |node| {
        if (node.next == null) {
            task.current_task.?.next = null;
            node.next = task.current_task;
            break;
        }
        tmp = node.next;
    }
    task.current_task = next_task.?;
}

pub fn yield() void {
    cpu.context_switch();
}

fn create_idle_task(stack: []usize, idle_handle: *task.task_handle) void {
    return task.thread_create(idle_handle, idle_tick, 32, stack);
}

pub fn run() void {
    var idle_id = task.thread_create_handle();
    var idle_stack = [_]usize{0} ** 1024;
    const idle_task = create_idle_task(&idle_stack, &idle_id);
    task.current_task.next = idle_task;
    cpu.context_switch();
}

const scheduler = struct {
    const t = task.head_task;
};
