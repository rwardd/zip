// Pre-emptive thread scheduler
const task = @import("../task/task.zig");
const logger = @import("../log.zig");

// TODO: find a better way to do this
const cpu = @import("../arch/riscv/rv32/cpu.zig");

fn idle_tick(args: ?*anyopaque) void {
    _ = args;
    while (true) {
        logger.log("Hello from idle task\n");
        yield();
    }
}

pub inline fn save_sp() void {
    asm volatile (
        \\sw sp, 0(%[curr_tcb])
        \\sw s0, 8(%[curr_tcb])
        :
        : [curr_tcb] "r" (&task.current_task.?.control),
        : "memory"
    );
}

pub fn switch_tasks() struct { old: ?*task.task_handle, new: ?*task.task_handle } {
    const old_head = task.head_task;
    task.head_task = task.head_task.?.next;
    var tmp: ?*task.task_handle = task.head_task;

    while (tmp) |node| {
        if (node.next == null) {
            break;
        }
        tmp = node.next;
    }

    old_head.?.next = null;
    tmp.?.next = old_head;
    task.current_task = task.head_task;
    return .{ .old = old_head, .new = task.current_task };
}

pub fn yield() void {
    cpu.context_switch();
}

fn create_idle_task(stack: []usize) task.task_handle {
    return task.task_create(&idle_tick, 32, stack);
}

pub fn run() void {
    task.current_task = task.head_task;
    cpu.exec_first_task(&task.current_task.?.control);
}

const scheduler = struct {
    const t = task.head_task;
};
