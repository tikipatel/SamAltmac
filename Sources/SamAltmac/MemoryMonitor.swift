import Foundation
import SamAltmacCore

@MainActor
final class MemoryMonitor: ObservableObject {
    @Published private(set) var sample: MemorySample?
    @Published private(set) var lastAlertDate: Date?

    @Published var threshold: Double {
        didSet { save(threshold, Keys.threshold); detector.threshold = threshold }
    }
    @Published var interval: Double {
        didSet { save(interval, Keys.interval); restartTimer() }
    }
    @Published var alertOnLaunchIfBelow: Bool {
        didSet { save(alertOnLaunchIfBelow, Keys.alertOnLaunch) }
    }

    private var detector: BelowThresholdDetector
    private var timer: Timer?
    private let notifier = Notifier()

    private enum Keys {
        static let threshold = "threshold"
        static let interval = "interval"
        static let alertOnLaunch = "alertOnLaunchIfBelow"
    }

    init() {
        let defaults = UserDefaults.standard
        defaults.register(defaults: [Keys.threshold: 80.0, Keys.interval: 5.0, Keys.alertOnLaunch: false])
        let threshold = defaults.double(forKey: Keys.threshold)
        let interval = defaults.double(forKey: Keys.interval)
        let alertOnLaunch = defaults.bool(forKey: Keys.alertOnLaunch)
        self.threshold = threshold
        self.interval = interval
        self.alertOnLaunchIfBelow = alertOnLaunch
        self.detector = BelowThresholdDetector(threshold: threshold,
                                               alertOnFirstReadingIfBelow: alertOnLaunch)
        notifier.requestAuthorization()
        tick()
        restartTimer()
    }

    var menuBarTitle: String {
        guard let sample else { return "Mem --" }
        return String(format: "Mem %.0f%%", sample.percent)
    }

    func sendTestAlert() {
        notifier.post(title: "SamAltmac",
                      body: "Test notification. You'll be alerted when memory usage drops below \(Int(threshold))%.")
    }

    private func restartTimer() {
        timer?.invalidate()
        let t = Timer(timeInterval: max(1, interval), repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func tick() {
        guard let sample = MemoryReader.sample() else { return }
        self.sample = sample
        if detector.update(percent: sample.percent) {
            lastAlertDate = Date()
            let used = ByteCountFormatter.string(fromByteCount: Int64(sample.usedBytes), countStyle: .memory)
            let total = ByteCountFormatter.string(fromByteCount: Int64(sample.totalBytes), countStyle: .memory)
            notifier.post(
                title: String(format: "Memory usage dropped below %.0f%%", threshold),
                body: String(format: "Now at %.1f%% (%@ of %@).", sample.percent, used, total)
            )
        }
    }

    private func save(_ value: Any, _ key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
}
