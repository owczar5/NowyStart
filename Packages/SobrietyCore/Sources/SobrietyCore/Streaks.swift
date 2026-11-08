import Foundation

/// Protocol representing a past streak interval ending with a restart.
public protocol RelapseRecord: Sendable {
    var previousStart: Date { get }
    var restartedAt: Date { get }
}

/// Standalone concrete implementation of `RelapseRecord`.
public struct SimpleRelapseRecord: RelapseRecord, Equatable, Sendable {
    public let previousStart: Date
    public let restartedAt: Date

    public init(previousStart: Date, restartedAt: Date) {
        self.previousStart = previousStart
        self.restartedAt = restartedAt
    }
}

/// Summary statistics for streaks, restarts, and historical durations.
public struct StreakSummary: Equatable, Sendable {
    public let currentStreakSeconds: TimeInterval
    public let longestStreakSeconds: TimeInterval
    public let restartCount: Int
    public let averageStreakSeconds: TimeInterval
    public let allStreakSeconds: [TimeInterval]

    public init(
        currentStreakSeconds: TimeInterval,
        longestStreakSeconds: TimeInterval,
        restartCount: Int,
        averageStreakSeconds: TimeInterval,
        allStreakSeconds: [TimeInterval]
    ) {
        self.currentStreakSeconds = currentStreakSeconds
        self.longestStreakSeconds = longestStreakSeconds
        self.restartCount = restartCount
        self.averageStreakSeconds = averageStreakSeconds
        self.allStreakSeconds = allStreakSeconds
    }

    public var currentStreakWholeDays: Int {
        Int(currentStreakSeconds / 86_400.0)
    }

    public var longestStreakWholeDays: Int {
        Int(longestStreakSeconds / 86_400.0)
    }

    public var averageStreakDays: Double {
        averageStreakSeconds / 86_400.0
    }
}

/// Calculator for sobriety streaks across restarts and current ongoing progress.
public struct StreakCalculator: Sendable {
    /// Computes streak statistics for a tracker and its associated relapses.
    /// - Parameters:
    ///   - currentStart: The start date of the current active streak.
    ///   - relapses: Historical relapses recorded for this tracker.
    ///   - now: The current reference date (defaults to `Date()`).
    /// - Returns: A complete `StreakSummary`.
    public static func calculate<R: RelapseRecord>(
        currentStart: Date,
        relapses: [R],
        now: Date = Date()
    ) -> StreakSummary {
        let currentSeconds = max(0.0, now.timeIntervalSince(currentStart))

        var pastSeconds: [TimeInterval] = []
        for relapse in relapses {
            let duration = max(0.0, relapse.restartedAt.timeIntervalSince(relapse.previousStart))
            pastSeconds.append(duration)
        }

        let allStreaks = pastSeconds + [currentSeconds]

        var maxSeconds = currentSeconds
        for duration in pastSeconds {
            if duration > maxSeconds {
                maxSeconds = duration
            }
        }

        let totalDuration = allStreaks.reduce(0.0, +)
        let average = allStreaks.isEmpty ? 0.0 : totalDuration / Double(allStreaks.count)

        return StreakSummary(
            currentStreakSeconds: currentSeconds,
            longestStreakSeconds: maxSeconds,
            restartCount: relapses.count,
            averageStreakSeconds: average,
            allStreakSeconds: allStreaks
        )
    }
}
