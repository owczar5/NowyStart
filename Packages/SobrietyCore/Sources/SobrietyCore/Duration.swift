import Foundation

/// Errors that can occur when calculating or validating time durations.
public enum DurationError: Error, Equatable, LocalizedError, Sendable {
    /// The start date is in the future relative to the reference date.
    case startInFuture(seconds: Double)
    /// The start date is further in the past than the allowed maximum (60 years).
    case startTooOld(years: Int)
    /// Calendar failed to calculate components between the given dates.
    case calendarCalculationFailed

    public var errorDescription: String? {
        switch self {
        case .startInFuture:
            return "Data rozpoczęcia nie może być w przyszłości."
        case .startTooOld:
            return "Data rozpoczęcia nie może być starsza niż 60 lat."
        case .calendarCalculationFailed:
            return "Nie udało się obliczyć jednostek czasu dla podanych dat."
        }
    }
}

/// Validates start dates for sobriety tracking.
public struct StartDateValidator: Sendable {
    public static let maxYearsPast: Int = 60

    /// Validates that a start date is not in the future and not older than 60 years.
    /// - Parameters:
    ///   - start: The candidate start date.
    ///   - now: The current reference date (defaults to current time).
    ///   - calendar: The calendar used for year boundary calculation.
    public static func validate(
        start: Date,
        now: Date = Date(),
        calendar: Calendar = .current
    ) throws {
        if start > now {
            let diff = start.timeIntervalSince(now)
            throw DurationError.startInFuture(seconds: diff)
        }

        guard let sixtyYearsAgo = calendar.date(byAdding: .year, value: -maxYearsPast, to: now) else {
            throw DurationError.calendarCalculationFailed
        }

        if start < sixtyYearsAgo {
            let components = calendar.dateComponents([.year], from: start, to: now)
            guard let years = components.year else {
                throw DurationError.calendarCalculationFailed
            }
            throw DurationError.startTooOld(years: years)
        }
    }
}

/// Represents the breakdown of elapsed time into calendar and physical units.
public struct DurationBreakdown: Equatable, Sendable {
    public let years: Int
    public let months: Int
    public let days: Int
    public let hours: Int
    public let minutes: Int
    public let seconds: Int
    public let totalDays: Int
    public let totalSeconds: TimeInterval

    /// Creates a duration breakdown between a start date and a reference date.
    /// - Parameters:
    ///   - start: The beginning of the tracked interval.
    ///   - now: The current reference date (defaults to `Date()`).
    ///   - calendar: The calendar to use for date component breakdown.
    public init(
        from start: Date,
        to now: Date = Date(),
        calendar: Calendar = .current
    ) throws {
        try StartDateValidator.validate(start: start, now: now, calendar: calendar)

        let elapsedSeconds = now.timeIntervalSince(start)
        self.totalSeconds = elapsedSeconds

        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: start,
            to: now
        )

        guard let years = components.year,
              let months = components.month,
              let days = components.day,
              let hours = components.hour,
              let minutes = components.minute,
              let seconds = components.second else {
            throw DurationError.calendarCalculationFailed
        }

        let dayComponents = calendar.dateComponents([.day], from: start, to: now)
        guard let totalDays = dayComponents.day else {
            throw DurationError.calendarCalculationFailed
        }

        self.years = years
        self.months = months
        self.days = days
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
        self.totalDays = totalDays
    }
}
