import Foundation

/// Represents a sobriety milestone achievement.
public struct Milestone: Identifiable, Equatable, Hashable, Sendable {
    public enum Unit: Equatable, Hashable, Sendable {
        case hour(Int)
        case day(Int)
        case year(Int)
    }

    public let id: String
    public let unit: Unit
    public let titleKey: String
    public let approximateSeconds: TimeInterval

    public init(id: String, unit: Unit, titleKey: String, approximateSeconds: TimeInterval) {
        self.id = id
        self.unit = unit
        self.titleKey = titleKey
        self.approximateSeconds = approximateSeconds
    }

    /// Computes the exact calendar target date for this milestone given a start date.
    public func targetDate(from start: Date, calendar: Calendar = .current) -> Date? {
        switch unit {
        case .hour(let h):
            return calendar.date(byAdding: .hour, value: h, to: start)
        case .day(let d):
            return calendar.date(byAdding: .day, value: d, to: start)
        case .year(let y):
            return calendar.date(byAdding: .year, value: y, to: start)
        }
    }
}

/// Represents an achieved milestone with the timestamp when it was reached.
public struct AchievedMilestone: Identifiable, Equatable, Sendable {
    public var id: String { milestone.id }
    public let milestone: Milestone
    public let achievedAt: Date

    public init(milestone: Milestone, achievedAt: Date) {
        self.milestone = milestone
        self.achievedAt = achievedAt
    }
}

/// Registry and calculator for sobriety milestones.
public struct Milestones: Sendable {
    /// Full catalog of milestones from 1 hour to 60 years.
    public static let catalog: [Milestone] = {
        var list: [Milestone] = [
            Milestone(id: "1h", unit: .hour(1), titleKey: "milestone.1h", approximateSeconds: 3600),
            Milestone(id: "6h", unit: .hour(6), titleKey: "milestone.6h", approximateSeconds: 6 * 3600),
            Milestone(id: "12h", unit: .hour(12), titleKey: "milestone.12h", approximateSeconds: 12 * 3600),
            Milestone(id: "24h", unit: .hour(24), titleKey: "milestone.24h", approximateSeconds: 24 * 3600),
            Milestone(id: "3d", unit: .day(3), titleKey: "milestone.3d", approximateSeconds: 3 * 86400),
            Milestone(id: "7d", unit: .day(7), titleKey: "milestone.7d", approximateSeconds: 7 * 86400),
            Milestone(id: "14d", unit: .day(14), titleKey: "milestone.14d", approximateSeconds: 14 * 86400),
            Milestone(id: "30d", unit: .day(30), titleKey: "milestone.30d", approximateSeconds: 30 * 86400),
            Milestone(id: "60d", unit: .day(60), titleKey: "milestone.60d", approximateSeconds: 60 * 86400),
            Milestone(id: "90d", unit: .day(90), titleKey: "milestone.90d", approximateSeconds: 90 * 86400),
            Milestone(id: "180d", unit: .day(180), titleKey: "milestone.180d", approximateSeconds: 180 * 86400),
            Milestone(id: "270d", unit: .day(270), titleKey: "milestone.270d", approximateSeconds: 270 * 86400),
            Milestone(id: "1y", unit: .year(1), titleKey: "milestone.1y", approximateSeconds: 365 * 86400)
        ]

        // Subsequent years from 2 to 60
        for y in 2...60 {
            let seconds = Double(y) * 365.0 * 86400.0
            list.append(
                Milestone(
                    id: "\(y)y",
                    unit: .year(y),
                    titleKey: "milestone.\(y)y",
                    approximateSeconds: seconds
                )
            )
        }

        return list
    }()

    /// Returns the next milestone strictly after the given elapsed seconds.
    public static func next(after elapsedSeconds: TimeInterval) -> Milestone? {
        return catalog.first { $0.approximateSeconds > elapsedSeconds }
    }

    /// Returns the previous reached milestone at or before the given elapsed seconds.
    public static func previous(before elapsedSeconds: TimeInterval) -> Milestone? {
        return catalog.last { $0.approximateSeconds <= elapsedSeconds }
    }

    /// Returns the next milestone strictly after the reference date given a start date and calendar.
    public static func next(
        from start: Date,
        at now: Date = Date(),
        calendar: Calendar = .current
    ) -> Milestone? {
        for milestone in catalog {
            guard let target = milestone.targetDate(from: start, calendar: calendar) else {
                continue
            }
            if target > now {
                return milestone
            }
        }
        return nil
    }

    /// Returns the most recently achieved milestone at or before the reference date.
    public static func previous(
        from start: Date,
        at now: Date = Date(),
        calendar: Calendar = .current
    ) -> Milestone? {
        var lastAchieved: Milestone? = nil
        for milestone in catalog {
            guard let target = milestone.targetDate(from: start, calendar: calendar) else {
                continue
            }
            if target <= now {
                lastAchieved = milestone
            } else {
                break
            }
        }
        return lastAchieved
    }

    /// Computes the fractional progress (0.0 ... 1.0) towards the next milestone.
    public static func progressToNext(
        start: Date,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> Double {
        if now <= start {
            return 0.0
        }

        guard let nextMilestone = next(from: start, at: now, calendar: calendar) else {
            return 1.0
        }

        guard let nextDate = nextMilestone.targetDate(from: start, calendar: calendar) else {
            return 1.0
        }

        let prevDate: Date
        if let prevMilestone = previous(from: start, at: now, calendar: calendar),
           let reachedDate = prevMilestone.targetDate(from: start, calendar: calendar) {
            prevDate = reachedDate
        } else {
            prevDate = start
        }

        let totalSpan = nextDate.timeIntervalSince(prevDate)
        guard totalSpan > 0 else {
            return 1.0
        }

        let elapsed = now.timeIntervalSince(prevDate)
        let ratio = elapsed / totalSpan
        return min(1.0, max(0.0, ratio))
    }

    /// Returns the list of all achieved milestones with their reached dates.
    public static func achieved(
        start: Date,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> [AchievedMilestone] {
        var results: [AchievedMilestone] = []
        for milestone in catalog {
            guard let target = milestone.targetDate(from: start, calendar: calendar) else {
                continue
            }
            if target <= now {
                results.append(AchievedMilestone(milestone: milestone, achievedAt: target))
            } else {
                break
            }
        }
        return results
    }
}
