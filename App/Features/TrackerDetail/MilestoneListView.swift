import SwiftUI
import SobrietyCore

/// Section displaying reached milestones with timestamps and the next upcoming milestone progress.
public struct MilestoneListView: View {
    public let startDate: Date
    public let tintColor: Color

    public init(startDate: Date, tintColor: Color = AppTheme.warmAccent) {
        self.startDate = startDate
        self.tintColor = tintColor
    }

    public var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { timeline in
            let now = timeline.date
            let achieved = Milestones.achieved(start: startDate, now: now)
            let next = Milestones.next(from: startDate, at: now)
            let progress = Milestones.progressToNext(start: startDate, now: now)

            VStack(alignment: .leading, spacing: 14) {
                Text("Kamienie milowe")
                    .font(.headline)
                    .foregroundStyle(.primary)

                // Next Milestone Banner
                if let nextMilestone = next {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Następny cel: \(nextMilestone.titleKey)")
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            Text("\(Int(progress * 100))%")
                                .font(.caption.weight(.medium))
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }

                        ProgressView(value: progress)
                            .tint(tintColor)

                        if let target = nextMilestone.targetDate(from: startDate) {
                            Text("Przewidywany termin: \(target.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(14)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Achieved Milestones
                if !achieved.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(achieved.reversed()) { item in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(tintColor)

                                Text(item.milestone.titleKey)
                                    .font(.subheadline)

                                Spacer()

                                Text(item.achievedAt.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(14)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}
