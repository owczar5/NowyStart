import SwiftUI
import SobrietyCore

/// Prominent live clock showing total days and unit breakdown (years, months, days, hours, min, sec).
public struct LiveClockView: View {
    public let startDate: Date
    public let tintColor: Color

    public init(startDate: Date, tintColor: Color = AppTheme.primaryNavy) {
        self.startDate = startDate
        self.tintColor = tintColor
    }

    public var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { timeline in
            let now = timeline.date
            let breakdown = (try? DurationBreakdown(from: startDate, to: now))
            let totalDays = breakdown?.totalDays ?? 0
            let hours = breakdown?.hours ?? 0
            let minutes = breakdown?.minutes ?? 0
            let seconds = breakdown?.seconds ?? 0

            VStack(spacing: 16) {
                // Large Days counter
                VStack(spacing: 2) {
                    Text("\(totalDays)")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.primary)

                    Text(PluralHelper.day.word(for: totalDays).uppercased())
                        .font(.caption.weight(.bold))
                        .tracking(1.5)
                        .foregroundStyle(.secondary)
                }

                // Live HH:MM:SS
                Text(TimeDisplayFormatter.formatHMS(hours: hours, minutes: minutes, seconds: seconds))
                    .font(.system(size: 26, weight: .semibold, design: .monospaced))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)

                // Calendar Units Breakdown
                if let b = breakdown, (b.years > 0 || b.months > 0) {
                    HStack(spacing: 16) {
                        if b.years > 0 {
                            unitItem(value: b.years, label: PluralHelper.year.word(for: b.years))
                        }
                        if b.months > 0 {
                            unitItem(value: b.months, label: PluralHelper.month.word(for: b.months))
                        }
                        unitItem(value: b.days, label: PluralHelper.day.word(for: b.days))
                    }
                    .padding(.top, 4)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                breakdown != nil ? TimeDisplayFormatter.voiceOverDescription(from: breakdown!) : "\(totalDays) dni"
            )
        }
    }

    private func unitItem(value: Int, label: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.headline)
                .monospacedDigit()
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
