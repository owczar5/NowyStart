import Foundation
import SobrietyCore

/// Formats time durations into monospaced clock strings and accessible VoiceOver descriptions.
public enum TimeDisplayFormatter {
    /// Formats hours, minutes, and seconds as "HH:MM:SS" with zero padding.
    public static func formatHMS(hours: Int, minutes: Int, seconds: Int) -> String {
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    /// Formats days and time as "X dni, HH:MM:SS".
    public static func formatDaysAndHMS(days: Int, hours: Int, minutes: Int, seconds: Int) -> String {
        let daysString = PluralHelper.day.format(value: days)
        let hms = formatHMS(hours: hours, minutes: minutes, seconds: seconds)
        return "\(daysString), \(hms)"
    }

    /// Builds a warm and natural accessibility phrase for VoiceOver screen readers.
    /// Example: "47 dni, 3 godziny, 12 minut".
    public static func voiceOverDescription(from breakdown: DurationBreakdown) -> String {
        var parts: [String] = []

        if breakdown.years > 0 {
            parts.append(PluralHelper.year.format(value: breakdown.years))
        }
        if breakdown.months > 0 {
            parts.append(PluralHelper.month.format(value: breakdown.months))
        }
        if breakdown.days > 0 || parts.isEmpty {
            parts.append(PluralHelper.day.format(value: breakdown.days))
        }
        if breakdown.hours > 0 {
            parts.append(PluralHelper.hour.format(value: breakdown.hours))
        }
        if breakdown.minutes > 0 {
            parts.append(PluralHelper.minute.format(value: breakdown.minutes))
        }

        return parts.joined(separator: ", ")
    }
}
