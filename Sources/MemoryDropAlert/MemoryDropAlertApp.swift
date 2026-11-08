import SwiftUI
import MemoryDropAlertCore

@main
struct MemoryDropAlertApp: App {
    @StateObject private var monitor = MemoryMonitor()

    var body: some Scene {
        MenuBarExtra {
            MenuContentView(monitor: monitor)
        } label: {
            Text(monitor.menuBarTitle).monospacedDigit()
        }
        .menuBarExtraStyle(.window)
    }
}

struct MenuContentView: View {
    @ObservedObject var monitor: MemoryMonitor

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Memory Drop Alert").font(.headline)

            if let sample = monitor.sample {
                ProgressView(value: min(sample.percent, 100), total: 100)
                    .tint(sample.percent < monitor.threshold ? .green : .orange)
                Text(String(format: "%.1f%% used", sample.percent)).font(.title2).monospacedDigit()
                Text("\(format(sample.usedBytes)) of \(format(sample.totalBytes))")
                    .font(.caption).foregroundStyle(.secondary)
            } else {
                Text("Reading memory…").foregroundStyle(.secondary)
            }

            Divider()

            Text("Alert when usage drops below \(Int(monitor.threshold))%")
                .font(.subheadline)
            Slider(value: $monitor.threshold, in: 10...95, step: 1)

            Picker("Check every", selection: $monitor.interval) {
                Text("2 s").tag(2.0)
                Text("5 s").tag(5.0)
                Text("15 s").tag(15.0)
                Text("60 s").tag(60.0)
            }
            Toggle("Alert at launch if already below", isOn: $monitor.alertOnLaunchIfBelow)
                .font(.caption)

            if let date = monitor.lastAlertDate {
                Text("Last alert: \(date.formatted(date: .omitted, time: .standard))")
                    .font(.caption).foregroundStyle(.secondary)
            }

            Divider()

            HStack {
                Button("Test Alert") { monitor.sendTestAlert() }
                Spacer()
                Button("Quit") { NSApplication.shared.terminate(nil) }
            }
        }
        .padding(14)
        .frame(width: 280)
    }

    private func format(_ bytes: UInt64) -> String {
        ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .memory)
    }
}
