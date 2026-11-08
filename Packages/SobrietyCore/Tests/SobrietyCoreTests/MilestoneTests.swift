import XCTest
@testable import SobrietyCore

final class MilestoneTests: XCTestCase {
    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return cal
    }

    /// Test 4: Milestones next and previous for boundary values (exactly 24h, 29d, 365d, 800d -> next anniversary).
    func testMilestoneBoundaries() {
        let hour: TimeInterval = 3600
        let day: TimeInterval = 86400

        // Exactly 24h
        let seconds24h = 24.0 * hour
        let prev24h = Milestones.previous(before: seconds24h)
        let next24h = Milestones.next(after: seconds24h)
        XCTAssertEqual(prev24h?.id, "24h")
        XCTAssertEqual(next24h?.id, "3d")

        // 29 days
        let seconds29d = 29.0 * day
        let prev29d = Milestones.previous(before: seconds29d)
        let next29d = Milestones.next(after: seconds29d)
        XCTAssertEqual(prev29d?.id, "14d")
        XCTAssertEqual(next29d?.id, "30d")

        // 365 days (1 year)
        let seconds365d = 365.0 * day
        let prev365d = Milestones.previous(before: seconds365d)
        let next365d = Milestones.next(after: seconds365d)
        XCTAssertEqual(prev365d?.id, "1y")
        XCTAssertEqual(next365d?.id, "2y")

        // 800 days (between 2 years = 730d and 3 years = 1095d -> next anniversary is 3 years)
        let seconds800d = 800.0 * day
        let prev800d = Milestones.previous(before: seconds800d)
        let next800d = Milestones.next(after: seconds800d)
        XCTAssertEqual(prev800d?.id, "2y")
        XCTAssertEqual(next800d?.id, "3y")
    }

    /// Test 5: progressToNext is in range 0..1 and monotonic within intervals.
    func testProgressToNextMonotonicityAndRange() {
        let cal = calendar
        let start = Date(timeIntervalSince1970: 1_700_000_000)

        // At exact start
        let initialProgress = Milestones.progressToNext(start: start, now: start, calendar: cal)
        XCTAssertEqual(initialProgress, 0.0, accuracy: 0.001)

        // Monotonicity test within 0..1h interval (steps of 10 minutes)
        var lastProgress: Double = -1.0
        for minute in 0...59 {
            let now = start.addingTimeInterval(Double(minute * 60))
            let p = Milestones.progressToNext(start: start, now: now, calendar: cal)

            XCTAssertGreaterThanOrEqual(p, 0.0, "Progress below 0.0 at minute \(minute)")
            XCTAssertLessThanOrEqual(p, 1.0, "Progress above 1.0 at minute \(minute)")
            XCTAssertGreaterThanOrEqual(p, lastProgress, "Progress decreased at minute \(minute)")
            lastProgress = p
        }

        // Monotonicity test between 14d and 30d (steps of 1 day)
        guard let day14 = cal.date(byAdding: .day, value: 14, to: start),
              let day30 = cal.date(byAdding: .day, value: 30, to: start) else {
            XCTFail("Failed to build milestone test dates")
            return
        }

        var lastDayProgress: Double = -1.0
        var current = day14
        while current < day30 {
            let p = Milestones.progressToNext(start: start, now: current, calendar: cal)
            XCTAssertGreaterThanOrEqual(p, 0.0)
            XCTAssertLessThanOrEqual(p, 1.0)
            XCTAssertGreaterThanOrEqual(p, lastDayProgress)
            lastDayProgress = p
            guard let nextDay = cal.date(byAdding: .day, value: 1, to: current) else { break }
            current = nextDay
        }
    }
}
