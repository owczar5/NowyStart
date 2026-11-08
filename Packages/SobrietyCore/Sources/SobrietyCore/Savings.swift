import Foundation

/// Utility for calculating avoided substance consumption and financial savings.
public struct Savings: Sendable {
    private static let secondsPerDay: Double = 86_400.0

    /// Calculates the estimated units avoided based on elapsed seconds and daily consumption rate.
    /// - Parameters:
    ///   - dailyUnits: Number of units consumed per day, or `nil` if not specified.
    ///   - elapsedSeconds: Elapsed time in seconds.
    /// - Returns: Units avoided as a `Double`, or `nil` if parameters are missing or invalid.
    public static func unitsAvoided(
        dailyUnits: Double?,
        elapsedSeconds: TimeInterval
    ) -> Double? {
        guard let dailyUnits, dailyUnits >= 0, elapsedSeconds >= 0 else {
            return nil
        }
        let fractionalDays = elapsedSeconds / secondsPerDay
        return dailyUnits * fractionalDays
    }

    /// Calculates the money saved based on daily units, unit price, and elapsed seconds.
    /// - Parameters:
    ///   - dailyUnits: Number of units consumed per day.
    ///   - unitPrice: Price per single unit.
    ///   - elapsedSeconds: Elapsed time in seconds.
    /// - Returns: Money saved as a `Decimal`, or `nil` if required data is missing or invalid.
    public static func moneySaved(
        dailyUnits: Double?,
        unitPrice: Decimal?,
        elapsedSeconds: TimeInterval
    ) -> Decimal? {
        guard let dailyUnits,
              let unitPrice,
              dailyUnits >= 0,
              unitPrice >= 0,
              elapsedSeconds >= 0 else {
            return nil
        }

        if unitPrice == 0 {
            return Decimal.zero
        }

        guard let avoided = unitsAvoided(dailyUnits: dailyUnits, elapsedSeconds: elapsedSeconds) else {
            return nil
        }

        let avoidedDecimal = Decimal(avoided)
        return avoidedDecimal * unitPrice
    }
}
