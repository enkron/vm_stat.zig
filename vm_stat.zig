const std = @import("std");

const c = @cImport({
    @cInclude("mach/mach_host.h");
    @cInclude("mach/mach_init.h");
    @cInclude("mach/vm_statistics.h");
});

pub fn main() !void {
    var stdout = std.io.getStdOut().writer();

    var count: c.mach_msg_type_number_t = @intCast(@sizeOf(c.vm_statistics_data_t) / @sizeOf(c.integer_t));
    var vmstat: c.vm_statistics_data_t = undefined;

    const host: c.host_t = c.mach_host_self();

    const result = c.host_statistics(
        host,
        c.HOST_VM_INFO,
        @ptrCast(&vmstat),
        &count,
    );

    if (result != c.KERN_SUCCESS) {
        std.debug.print("host_statistics failed\n", .{});
        return;
    }

    // MacOS default page size
    const page_size: usize = 4096;

    try stdout.print("Pages free: {}.\n", .{vmstat.free_count});
    try stdout.print("free: {} Mi\n", .{vmstat.free_count * page_size / 1024 / 1024});
}
