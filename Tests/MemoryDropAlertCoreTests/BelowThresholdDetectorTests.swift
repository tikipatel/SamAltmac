import XCTest
@testable import MemoryDropAlertCore

final class BelowThresholdDetectorTests: XCTestCase {
    let t0 = Date(timeIntervalSince1970: 0)

    func testDoesNotAlertWhenAboveThreshold() {
        var d = BelowThresholdDetector(threshold: 80)
        XCTAssertFalse(d.update(percent: 85, at: t0))
        XCTAssertFalse(d.update(percent: 95, at: t0.addingTimeInterval(5)))
    }

    func testAlertsWhenDroppingBelowThreshold() {
        var d = BelowThresholdDetector(threshold: 80)
        XCTAssertFalse(d.update(percent: 82, at: t0))
        XCTAssertTrue(d.update(percent: 79, at: t0.addingTimeInterval(5)))
    }

    func testAlertsOnlyOncePerDrop() {
        var d = BelowThresholdDetector(threshold: 80)
        _ = d.update(percent: 82, at: t0)
        XCTAssertTrue(d.update(percent: 70, at: t0.addingTimeInterval(5)))
        XCTAssertFalse(d.update(percent: 60, at: t0.addingTimeInterval(500)))
    }

    func testRearmsAfterGoingBackAbove() {
        var d = BelowThresholdDetector(threshold: 80, cooldown: 0)
        _ = d.update(percent: 82, at: t0)
        XCTAssertTrue(d.update(percent: 70, at: t0.addingTimeInterval(5)))
        XCTAssertFalse(d.update(percent: 81, at: t0.addingTimeInterval(10)))
        XCTAssertTrue(d.update(percent: 75, at: t0.addingTimeInterval(15)))
    }

    func testExactlyAtThresholdIsNotBelow() {
        var d = BelowThresholdDetector(threshold: 80)
        _ = d.update(percent: 90, at: t0)
        XCTAssertFalse(d.update(percent: 80, at: t0.addingTimeInterval(5)))
        XCTAssertTrue(d.update(percent: 79.9, at: t0.addingTimeInterval(10)))
    }

    func testCooldownSuppressesFlappingThenFires() {
        var d = BelowThresholdDetector(threshold: 80, cooldown: 60)
        _ = d.update(percent: 81, at: t0)
        XCTAssertTrue(d.update(percent: 79, at: t0.addingTimeInterval(1)))
        _ = d.update(percent: 81, at: t0.addingTimeInterval(2))
        XCTAssertFalse(d.update(percent: 79, at: t0.addingTimeInterval(3)))
        XCTAssertTrue(d.update(percent: 79, at: t0.addingTimeInterval(62)))
    }

    func testNoAlertOnFirstReadingBelowByDefault() {
        var d = BelowThresholdDetector(threshold: 80)
        XCTAssertFalse(d.update(percent: 50, at: t0))
    }

    func testOptionalAlertOnFirstReadingBelow() {
        var d = BelowThresholdDetector(threshold: 80, alertOnFirstReadingIfBelow: true)
        XCTAssertTrue(d.update(percent: 50, at: t0))
        XCTAssertFalse(d.update(percent: 50, at: t0.addingTimeInterval(120)))
    }

    func testMemoryReaderReturnsSaneValues() throws {
        let sample = try XCTUnwrap(MemoryReader.sample())
        XCTAssertGreaterThan(sample.totalBytes, 0)
        XCTAssertGreaterThan(sample.usedBytes, 0)
        XCTAssertLessThanOrEqual(sample.percent, 100)
    }
}
