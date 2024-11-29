// Pre-emptive thread scheduler
const task = @import("../task/task.zig");

// TODO: find a better way to do this
const cpu = @import("../arch/riscv/rv32/cpu.zig");

fn idle_tick(args: ?*anyopaque) void {
    _ = args;
    while (true) {
        yield();
    }
}

pub fn switch_tasks() void {
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
}

pub fn yield() void {
    // immediately save return address. This is pretty bad though so find better
    // way
    asm volatile (
        \\sw ra, 4(%[curr_tcb])
        :
        : [curr_tcb] "r" (&task.current_task.?.control),
        : "memory"
    );
    cpu.context_switch();
}

fn create_idle_task(stack: []usize) task.task_handle {
    return task.task_create(&idle_tick, 32, stack);
}

pub fn run() void {
    var idle_stack = [_]usize{0} ** 256;
    var idle_task = create_idle_task(&idle_stack);

    idle_task.control.id = 32;
    idle_task.control.sp = @intFromPtr(idle_task.control.stack.ptr);
    idle_task.control.ra = @intFromPtr(idle_task.tick);
    idle_task.next = task.head_task;
    task.head_task = &idle_task;
    cpu.context_switch();
}

const scheduler = struct {
    const t = task.head_task;
};
