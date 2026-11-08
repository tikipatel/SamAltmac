import Darwin
import Foundation

/// A single memory usage reading.
public struct MemorySample: Equatable {
    public let usedBytes: UInt64
    public let totalBytes: UInt64

    public init(usedBytes: UInt64, totalBytes: UInt64) {
        self.usedBytes = usedBytes
        self.totalBytes = totalBytes
    }

    /// Used memory as a percentage of physical memory (0–100).
    public var percent: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(usedBytes) / Double(totalBytes) * 100
    }
}

/// Reads system memory usage using the same formula as Activity Monitor's
/// "Memory Used": app memory + wired memory + compressed memory.
public enum MemoryReader {
    private static let host = mach_host_self()

    public static func sample() -> MemorySample? {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(
            MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size
        )
        let result = withUnsafeMutablePointer(to: &stats) { pointer in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(host, HOST_VM_INFO64, $0, &count)
            }
        }
        guard result == KERN_SUCCESS else { return nil }

        let pageSize = UInt64(vm_kernel_page_size)
        let internalPages = UInt64(stats.internal_page_count)
        let purgeablePages = UInt64(stats.purgeable_count)
        let appPages = internalPages > purgeablePages ? internalPages - purgeablePages : 0
        let wiredPages = UInt64(stats.wire_count)
        let compressedPages = UInt64(stats.compressor_page_count)

        let used = (appPages + wiredPages + compressedPages) * pageSize
        let total = ProcessInfo.processInfo.physicalMemory
        return MemorySample(usedBytes: min(used, total), totalBytes: total)
    }
}
