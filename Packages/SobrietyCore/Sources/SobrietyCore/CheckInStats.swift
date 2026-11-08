import Foundation

/// Protocol representing a check-in log entry.
public protocol CheckInRecord: Sendable {
    var date: Date { get }
    var mood: Int { get }
    var craving: Int { get }
    var triggers: [String] { get }
}

/// Standalone concrete implementation of `CheckInRecord`.
public struct SimpleCheckInRecord: CheckInRecord, Equatable, Sendable {
    public let date: Date
    public let mood: Int
    public let craving: Int
    public let triggers: [String]

    public init(date: Date, mood: Int, craving: Int, triggers: [String] = []) {
        self.date = date
        self.mood = mood
        self.craving = craving
        self.triggers = triggers
    }
}

/// Trigger occurrence count for analytics.
public struct TriggerCount: Equatable, Sendable {
    public let trigger: String
    public let count: Int

    public init(trigger: String, count: Int) {
        self.trigger = trigger
        self.count = count
    }
}

/// Statistics and analytics derived from check-in logs.
public struct CheckInStats: Sendable {
    /// Computes consecutive days with at least one check-in.
    /// Gaps in consecutive calendar days break the streak.
    /// If today has no entry yet, an active streak from yesterday is preserved.
    /// - Parameters:
    ///   - checkIns: Historical check-in logs.
    ///   - now: Current reference date.
    ///   - calendar: Calendar used for day boundaries.
    /// - Returns: Consecutive days count.
    public static func checkInStreak<C: CheckInRecord>(
        checkIns: [C],
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        if checkIns.isEmpty {
            return 0
        }

        let loggedDays = Set(checkIns.map { calendar.startOfDay(for: $0.date) })
        let today = calendar.startOfDay(for: now)

        let startDay: Date
        if loggedDays.contains(today) {
            startDay = today
        } else {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else {
                return 0
            }
            if loggedDays.contains(yesterday) {
                startDay = yesterday
            } else {
                return 0
            }
        }

        var streak = 0
        var currentDay = startDay

        while loggedDays.contains(currentDay) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDay) else {
                break
            }
            currentDay = previousDay
        }

        return streak
    }

    /// Computes average mood (scale 1–5) in the last `days` window.
    /// - Parameters:
    ///   - checkIns: Check-ins to analyze.
    ///   - days: Window size in calendar days (e.g. 7 or 30).
    ///   - now: Current reference date.
    ///   - calendar: Calendar to compute day boundaries.
    /// - Returns: Average mood, or `nil` if no check-ins exist in this window.
    public static func averageMood<C: CheckInRecord>(
        checkIns: [C],
        days: Int,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> Double? {
        let entries = filterWindow(checkIns: checkIns, days: days, now: now, calendar: calendar)
        guard !entries.isEmpty else { return nil }
        let total = entries.reduce(0) { $0 + $1.mood }
        return Double(total) / Double(entries.count)
    }

    /// Computes average craving intensity (scale 0–10) in the last `days` window.
    /// - Parameters:
    ///   - checkIns: Check-ins to analyze.
    ///   - days: Window size in calendar days.
    ///   - now: Current reference date.
    ///   - calendar: Calendar to compute day boundaries.
    /// - Returns: Average craving, or `nil` if no check-ins exist in this window.
    public static func averageCraving<C: CheckInRecord>(
        checkIns: [C],
        days: Int,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> Double? {
        let entries = filterWindow(checkIns: checkIns, days: days, now: now, calendar: calendar)
        guard !entries.isEmpty else { return nil }
        let total = entries.reduce(0) { $0 + $1.craving }
        return Double(total) / Double(entries.count)
    }

    /// Computes the most frequent triggers recorded in check-ins.
    /// - Parameters:
    ///   - checkIns: Check-ins to analyze.
    ///   - limit: Maximum number of triggers to return.
    /// - Returns: Array of `TriggerCount` sorted descending by frequency.
    public static func mostFrequentTriggers<C: CheckInRecord>(
        checkIns: [C],
        limit: Int = 5
    ) -> [TriggerCount] {
        var counts: [String: Int] = [:]
        for entry in checkIns {
            for trigger in entry.triggers {
                let trimmed = trigger.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { continue }
                counts[trimmed, default: 0] += 1
            }
        }

        let sorted = counts
            .map { TriggerCount(trigger: $0.key, count: $0.value) }
            .sorted { a, b in
                if a.count != b.count {
                    return a.count > b.count
                }
                return a.trigger < b.trigger
            }

        return Array(sorted.prefix(limit))
    }

    private static func filterWindow<C: CheckInRecord>(
        checkIns: [C],
        days: Int,
        now: Date,
        calendar: Calendar
    ) -> [C] {
        guard let windowStart = calendar.date(byAdding: .day, value: -days, to: now) else {
            return []
        }
        return checkIns.filter { $0.date >= windowStart && $0.date <= now }
    }
}
