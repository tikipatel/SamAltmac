import Foundation

/// Decides when to alert that memory usage has dropped BELOW a threshold.
///
/// The detector is "armed" whenever usage is at or above the threshold. When
/// usage then falls below the threshold, it fires once and disarms until usage
/// climbs back to the threshold again. A cooldown prevents a burst of alerts
/// when usage hovers right around the threshold.
public struct BelowThresholdDetector {
    public var threshold: Double
    public var cooldown: TimeInterval
    /// When true, an alert also fires if usage is already below the threshold
    /// on the very first reading (e.g. right after launch).
    public var alertOnFirstReadingIfBelow: Bool

    public private(set) var isArmed: Bool
    private var hasReading = false
    private var lastAlert: Date?

    public init(threshold: Double = 80,
                cooldown: TimeInterval = 60,
                alertOnFirstReadingIfBelow: Bool = false) {
        self.threshold = threshold
        self.cooldown = cooldown
        self.alertOnFirstReadingIfBelow = alertOnFirstReadingIfBelow
        self.isArmed = false
    }

    /// Feed a new reading. Returns `true` when an alert should be shown.
    public mutating func update(percent: Double, at date: Date = Date()) -> Bool {
        defer { hasReading = true }

        if percent >= threshold {
            isArmed = true
            return false
        }

        if !hasReading && alertOnFirstReadingIfBelow {
            isArmed = true
        }

        guard isArmed else { return false }
        if let lastAlert, date.timeIntervalSince(lastAlert) < cooldown {
            // Stay armed; alert once the cooldown expires if still below.
            return false
        }

        isArmed = false
        lastAlert = date
        return true
    }

    /// Forget all history (used when settings change).
    public mutating func reset() {
        isArmed = false
        hasReading = false
        lastAlert = nil
    }
}
