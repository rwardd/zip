const logger = @import("../log.zig");

pub const thread_fn = *const fn (args: ?*anyopaque) void;

const tcb = struct {
    id: u32 = 0,
    priority: u32 = 0,
    sp: usize = 0,
    next: ?*tcb = null,
};

// TODO: properly implement this
var head_tcb: ?*tcb = null;
var current_tcb: ?*tcb = null;

/// More stuff to go in here:
///     - tick fn
///     - stack addr
pub const thread_handle = struct {
    control: tcb,
    tick: ?thread_fn = null,
};

pub fn get_thread_id() u32 {
    return current_tcb.?.id;
}

pub fn get_thread_priority() u32 {
    return current_tcb.?.priority;
}

pub fn get_first_thread_prio() u32 {
    return head_tcb.?.priority;
}

pub fn thread_create_handle() thread_handle {
    return thread_handle{
        .control = tcb{},
    };
}

pub fn get_thread_tcb(id: u32) ?*tcb {
    var current = head_tcb;
    while (current) |cur| {
        if (cur.id == id) {
            return cur;
        }
        current = cur.next;
    }

    return null;
}

pub fn thread_create(handle: *thread_handle, tick_fn: thread_fn, id: u32, priority: u32) void {
    handle.control.priority = priority;
    handle.control.id = id;
    handle.tick = tick_fn;

    if (current_tcb) |current| {
        current.next = &handle.control;
        current_tcb = &handle.control;
    } else {
        current_tcb = &handle.control;
        head_tcb = current_tcb;
    }
}
