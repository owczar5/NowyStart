import XCTest
@testable import SobrietyCore

final class StreakTests: XCTestCase {
    /// Test 7: Longest streak after multiple restarts, current active streak, and average streak duration.
    func testStreakCalculationsAcrossMultipleRestarts() {
        let baseDate = Date(timeIntervalSince1970: 1_700_000_000)
        let day: TimeInterval = 86_400.0

        // Relapse 1: 10 days
        let r1Start = baseDate
        let r1Restart = baseDate.addingTimeInterval(10 * day)

        // Relapse 2: 25 days
        let r2Start = r1Restart
        let r2Restart = r2Start.addingTimeInterval(25 * day)

        // Relapse 3: 5 days
        let r3Start = r2Restart
        let r3Restart = r3Start.addingTimeInterval(5 * day)

        let relapses: [SimpleRelapseRecord] = [
            SimpleRelapseRecord(previousStart: r1Start, restartedAt: r1Restart),
            SimpleRelapseRecord(previousStart: r2Start, restartedAt: r2Restart),
            SimpleRelapseRecord(previousStart: r3Start, restartedAt: r3Restart)
        ]

        // Current active streak: 8 days
        let currentStart = r3Restart
        let now = currentStart.addingTimeInterval(8 * day)

        let summary = StreakCalculator.calculate(
            currentStart: currentStart,
            relapses: relapses,
            now: now
        )

        // Verify restarts count
        XCTAssertEqual(summary.restartCount, 3)

        // Verify current streak (8 days)
        XCTAssertEqual(summary.currentStreakSeconds, 8 * day)
        XCTAssertEqual(summary.currentStreakWholeDays, 8)

        // Verify longest streak (25 days from Relapse 2)
        XCTAssertEqual(summary.longestStreakSeconds, 25 * day)
        XCTAssertEqual(summary.longestStreakWholeDays, 25)

        // Verify average streak: (10 + 25 + 5 + 8) / 4 = 48 / 4 = 12 days
        XCTAssertEqual(summary.averageStreakSeconds, 12 * day)
        XCTAssertEqual(summary.averageStreakDays, 12.0, accuracy: 0.001)
    }

    /// Edge case: Tracker with zero restarts (only current ongoing streak).
    func testStreakWithoutRestarts() {
        let baseDate = Date(timeIntervalSince1970: 1_700_000_000)
        let day: TimeInterval = 86_400.0
        let now = baseDate.addingTimeInterval(14 * day)

        let summary = StreakCalculator.calculate(
            currentStart: baseDate,
            relapses: [],
            now: now
        )

        XCTAssertEqual(summary.restartCount, 0)
        XCTAssertEqual(summary.currentStreakWholeDays, 14)
        XCTAssertEqual(summary.longestStreakWholeDays, 14)
        XCTAssertEqual(summary.averageStreakDays, 14.0, accuracy: 0.001)
    }
}
