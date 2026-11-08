import XCTest
@testable import SobrietyCore

final class DurationTests: XCTestCase {
    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "Europe/Warsaw") ?? .current
        return cal
    }

    /// Test 1: Exact boundaries (59s -> 0m 59s, 60s -> 1m), breakdown of years/months/days, future start throws.
    func testDurationBoundariesAndBreakdown() throws {
        let cal = calendar
        guard let baseDate = cal.date(from: DateComponents(year: 2024, month: 1, day: 1, hour: 12, minute: 0, second: 0)) else {
            XCTFail("Failed to build base date")
            return
        }

        // 59 seconds boundary
        let after59s = baseDate.addingTimeInterval(59)
        let breakdown59s = try DurationBreakdown(from: baseDate, to: after59s, calendar: cal)
        XCTAssertEqual(breakdown59s.minutes, 0)
        XCTAssertEqual(breakdown59s.seconds, 59)
        XCTAssertEqual(breakdown59s.totalSeconds, 59.0)

        // 60 seconds boundary
        let after60s = baseDate.addingTimeInterval(60)
        let breakdown60s = try DurationBreakdown(from: baseDate, to: after60s, calendar: cal)
        XCTAssertEqual(breakdown60s.minutes, 1)
        XCTAssertEqual(breakdown60s.seconds, 0)
        XCTAssertEqual(breakdown60s.totalSeconds, 60.0)

        // Multi-unit breakdown (years, months, days, hours, minutes, seconds)
        guard let laterDate = cal.date(from: DateComponents(year: 2026, month: 4, day: 15, hour: 16, minute: 30, second: 45)) else {
            XCTFail("Failed to build later date")
            return
        }
        let fullBreakdown = try DurationBreakdown(from: baseDate, to: laterDate, calendar: cal)
        XCTAssertEqual(fullBreakdown.years, 2)
        XCTAssertEqual(fullBreakdown.months, 3)
        XCTAssertEqual(fullBreakdown.days, 14)
        XCTAssertEqual(fullBreakdown.hours, 4)
        XCTAssertEqual(fullBreakdown.minutes, 30)
        XCTAssertEqual(fullBreakdown.seconds, 45)
        XCTAssertGreaterThan(fullBreakdown.totalDays, 800)

        // Future start throws explicit error
        let futureStart = baseDate.addingTimeInterval(300)
        XCTAssertThrowsError(try DurationBreakdown(from: futureStart, to: baseDate, calendar: cal)) { error in
            guard case DurationError.startInFuture = error else {
                XCTFail("Expected DurationError.startInFuture but got \(error)")
                return
            }
        }
    }

    /// Test 2: Daylight saving time transition: totalSeconds is accurate physical seconds, totalDays matches Calendar.
    func testDurationDuringDaylightSavingTime() throws {
        var cal = Calendar(identifier: .gregorian)
        guard let warsawZone = TimeZone(identifier: "Europe/Warsaw") else {
            XCTFail("Timezone Europe/Warsaw not found")
            return
        }
        cal.timeZone = warsawZone

        // Spring forward: 2024-03-31 (at 02:00 clocks jumped to 03:00 -> 23 hours day)
        guard let startSpring = cal.date(from: DateComponents(year: 2024, month: 3, day: 30, hour: 12, minute: 0, second: 0)),
              let endSpring = cal.date(from: DateComponents(year: 2024, month: 3, day: 31, hour: 12, minute: 0, second: 0)) else {
            XCTFail("Failed to build spring transition dates")
            return
        }

        let springBreakdown = try DurationBreakdown(from: startSpring, to: endSpring, calendar: cal)
        // Physical duration is 23 hours
        XCTAssertEqual(springBreakdown.totalSeconds, 23.0 * 3600.0)
        // Calendar days is 1
        XCTAssertEqual(springBreakdown.totalDays, 1)

        // Fall back: 2024-10-27 (at 03:00 clocks jumped back to 02:00 -> 25 hours day)
        guard let startAutumn = cal.date(from: DateComponents(year: 2024, month: 10, day: 26, hour: 12, minute: 0, second: 0)),
              let endAutumn = cal.date(from: DateComponents(year: 2024, month: 10, day: 27, hour: 12, minute: 0, second: 0)) else {
            XCTFail("Failed to build autumn transition dates")
            return
        }

        let autumnBreakdown = try DurationBreakdown(from: startAutumn, to: endAutumn, calendar: cal)
        // Physical duration is 25 hours
        XCTAssertEqual(autumnBreakdown.totalSeconds, 25.0 * 3600.0)
        // Calendar days is 1
        XCTAssertEqual(autumnBreakdown.totalDays, 1)
    }

    /// Test 3: Start date validation rejects future and older than 60 years.
    func testStartDateValidation() throws {
        let cal = calendar
        let now = Date()

        // Valid past date (1 year ago)
        guard let oneYearAgo = cal.date(byAdding: .year, value: -1, to: now) else {
            XCTFail("Failed to compute 1 year ago")
            return
        }
        XCTAssertNoThrow(try StartDateValidator.validate(start: oneYearAgo, now: now, calendar: cal))

        // Valid boundary: 59 years ago
        guard let fiftyNineYearsAgo = cal.date(byAdding: .year, value: -59, to: now) else {
            XCTFail("Failed to compute 59 years ago")
            return
        }
        XCTAssertNoThrow(try StartDateValidator.validate(start: fiftyNineYearsAgo, now: now, calendar: cal))

        // Invalid: future date
        let futureDate = now.addingTimeInterval(120)
        XCTAssertThrowsError(try StartDateValidator.validate(start: futureDate, now: now, calendar: cal)) { error in
            guard case DurationError.startInFuture = error else {
                XCTFail("Expected startInFuture, got \(error)")
                return
            }
        }

        // Invalid: older than 60 years
        guard let sixtyOneYearsAgo = cal.date(byAdding: .year, value: -61, to: now) else {
            XCTFail("Failed to compute 61 years ago")
            return
        }
        XCTAssertThrowsError(try StartDateValidator.validate(start: sixtyOneYearsAgo, now: now, calendar: cal)) { error in
            guard case DurationError.startTooOld = error else {
                XCTFail("Expected startTooOld, got \(error)")
                return
            }
        }
    }
}
