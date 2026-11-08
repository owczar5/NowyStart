import XCTest
@testable import SobrietyCore

final class CheckInStatsTests: XCTestCase {
    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return cal
    }

    /// Test 8: Check-in streak with gaps, average mood and cravings across 7 and 30 day windows.
    func testCheckInStreakWithGapsAndAverages() {
        let cal = calendar
        guard let now = cal.date(from: DateComponents(year: 2024, month: 6, day: 10, hour: 14, minute: 0, second: 0)) else {
            XCTFail("Failed to build base date")
            return
        }

        func dateDaysAgo(_ days: Int) -> Date {
            return cal.date(byAdding: .day, value: -days, to: now) ?? now
        }

        // Check-ins: Today (0), yesterday (1), 2 days ago (2).
        // Gap at day 3 (missing!).
        // Older check-ins at day 4 and 5.
        let checkInsWithGap: [SimpleCheckInRecord] = [
            SimpleCheckInRecord(date: dateDaysAgo(0), mood: 4, craving: 2, triggers: ["Stres"]),
            SimpleCheckInRecord(date: dateDaysAgo(1), mood: 5, craving: 1, triggers: ["Stres", "Zmęczenie"]),
            SimpleCheckInRecord(date: dateDaysAgo(2), mood: 3, craving: 3, triggers: ["Nuda"]),
            // day 3 missing!
            SimpleCheckInRecord(date: dateDaysAgo(4), mood: 2, craving: 7, triggers: ["Stres"]),
            SimpleCheckInRecord(date: dateDaysAgo(5), mood: 2, craving: 8, triggers: ["Kłótnia"]),
            // 20 days ago (within 30d, outside 7d)
            SimpleCheckInRecord(date: dateDaysAgo(20), mood: 1, craving: 9, triggers: ["Stres"])
        ]

        // Streak test: should be 3 because day 3 is missing
        let streak = CheckInStats.checkInStreak(checkIns: checkInsWithGap, now: now, calendar: cal)
        XCTAssertEqual(streak, 3)

        // Streak test: today not yet logged, but yesterday logged -> streak preserved as 2
        let checkInsNoToday: [SimpleCheckInRecord] = [
            SimpleCheckInRecord(date: dateDaysAgo(1), mood: 4, craving: 2),
            SimpleCheckInRecord(date: dateDaysAgo(2), mood: 4, craving: 2)
        ]
        let streakYesterday = CheckInStats.checkInStreak(checkIns: checkInsNoToday, now: now, calendar: cal)
        XCTAssertEqual(streakYesterday, 2)

        // Streak test: neither today nor yesterday logged -> streak broken (0)
        let checkInsBroken: [SimpleCheckInRecord] = [
            SimpleCheckInRecord(date: dateDaysAgo(2), mood: 4, craving: 2)
        ]
        let streakBroken = CheckInStats.checkInStreak(checkIns: checkInsBroken, now: now, calendar: cal)
        XCTAssertEqual(streakBroken, 0)

        // 7-day window averages (includes days 0, 1, 2, 4, 5 -> 5 entries)
        // Moods: 4, 5, 3, 2, 2 -> sum = 16 / 5 = 3.2
        // Cravings: 2, 1, 3, 7, 8 -> sum = 21 / 5 = 4.2
        let avgMood7 = CheckInStats.averageMood(checkIns: checkInsWithGap, days: 7, now: now, calendar: cal)
        let avgCraving7 = CheckInStats.averageCraving(checkIns: checkInsWithGap, days: 7, now: now, calendar: cal)

        guard let avgMood7, let avgCraving7 else {
            XCTFail("Expected non-nil 7-day averages")
            return
        }
        XCTAssertEqual(avgMood7, 3.2, accuracy: 0.001)
        XCTAssertEqual(avgCraving7, 4.2, accuracy: 0.001)

        // 30-day window averages (all 6 entries, including day 20 with mood 1, craving 9)
        // Moods sum = 16 + 1 = 17 / 6 = 2.833
        // Cravings sum = 21 + 9 = 30 / 6 = 5.0
        let avgMood30 = CheckInStats.averageMood(checkIns: checkInsWithGap, days: 30, now: now, calendar: cal)
        let avgCraving30 = CheckInStats.averageCraving(checkIns: checkInsWithGap, days: 30, now: now, calendar: cal)

        guard let avgMood30, let avgCraving30 else {
            XCTFail("Expected non-nil 30-day averages")
            return
        }
        XCTAssertEqual(avgMood30, 17.0 / 6.0, accuracy: 0.001)
        XCTAssertEqual(avgCraving30, 5.0, accuracy: 0.001)

        // Triggers ranking:
        // "Stres" appeared 4 times (days 0, 1, 4, 20)
        // "Zmęczenie" appeared 1 time
        // "Nuda" appeared 1 time
        // "Kłótnia" appeared 1 time
        let topTriggers = CheckInStats.mostFrequentTriggers(checkIns: checkInsWithGap, limit: 3)
        XCTAssertEqual(topTriggers.count, 3)
        XCTAssertEqual(topTriggers.first?.trigger, "Stres")
        XCTAssertEqual(topTriggers.first?.count, 4)
    }
}
