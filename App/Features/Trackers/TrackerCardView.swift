import SwiftUI
import SobrietyCore

/// Card presenting an individual sobriety tracker with a live clock and milestone progress.
public struct TrackerCardView: View {
    public let tracker: Tracker
    public let isDiscreet: Bool

    public init(tracker: Tracker, isDiscreet: Bool = false) {
        self.tracker = tracker
        self.isDiscreet = isDiscreet
    }

    public var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { timeline in
            let now = timeline.date
            let breakdown = (try? DurationBreakdown(from: tracker.startDate, to: now))
            let days = breakdown?.totalDays ?? 0
            let hours = breakdown?.hours ?? 0
            let minutes = breakdown?.minutes ?? 0
            let seconds = breakdown?.seconds ?? 0
            let progress = Milestones.progressToNext(start: tracker.startDate, now: now)
            let nextMilestone = Milestones.next(from: tracker.startDate, at: now)

            VStack(alignment: .leading, spacing: 14) {
                // Header: Symbol + Name
                HStack(spacing: 12) {
                    Image(systemName: TrackerDisplayHelper.displaySymbol(for: tracker, discreet: isDiscreet))
                        .font(.title3)
                        .foregroundStyle(AppTheme.color(for: tracker.colorToken))
                        .frame(width: 36, height: 36)
                        .background(AppTheme.color(for: tracker.colorToken).opacity(0.12))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(TrackerDisplayHelper.displayName(for: tracker, discreet: isDiscreet))
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        if let next = nextMilestone {
                            Text("Cel: \(next.titleKey)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    TrackerProgressRing(progress: progress, tintColor: AppTheme.color(for: tracker.colorToken), lineWidth: 6)
                        .frame(width: 44, height: 44)
                }

                // Numbers: Days + HH:MM:SS
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(days)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.primary)

                    Text(PluralHelper.day.word(for: days))
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(TimeDisplayFormatter.formatHMS(hours: hours, minutes: minutes, seconds: seconds))
                        .font(.system(size: 18, weight: .medium, design: .monospaced))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            .padding(18)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                "\(TrackerDisplayHelper.displayName(for: tracker, discreet: isDiscreet)), \(breakdown != nil ? TimeDisplayFormatter.voiceOverDescription(from: breakdown!) : "\(days) dni")"
            )
        }
    }
}
