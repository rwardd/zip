//! Helper file to compute the RP2040 bootloader CRC and output a final binary

const std = @import("std");

/// Main function to take an input argument to a bootloader binary path, and output a CRC'd bootloader
/// binary
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) return error.InvalidArgs;
    const path = args.ptr[1];

    // We can error out here if the bootloader size is greater than 252 bytes (to allow 4 bytes for
    // CRC checksum)
    const bootloader_file = try std.fs.cwd().readFileAlloc(allocator, path, 252);
    defer allocator.free(bootloader_file);

    // Compute CRC and transform into an 8 bit slice to load into the finalised bootloader binary
    const crc = std.hash.crc.Crc32Mpeg2;
    const crc_data = crc.hash(bootloader_file);
    var crc_data_slice = [_]u8{ 0, 0, 0, 0 };
    for (0..4) |i| {
        crc_data_slice[i] = @truncate((crc_data >> @intCast(i * 8)) & 0xFF);
    }

    // Generate a final bootloader file with the bootloader code + checksum
    const bootloader_checked = try std.fs.cwd().createFile(
        "boot.bin",
        .{ .read = true },
    );
    defer bootloader_checked.close();

    // Write bootloader
    var bytes_written = try bootloader_checked.write(bootloader_file);
    if (bytes_written != 252) {
        return error.InvalidBootloaderWrite;
    }

    // Write checksum
    bytes_written = try bootloader_checked.write(&crc_data_slice);
    if (bytes_written != 4) {
        return error.InvalidBootloaderWrite;
    }
}
