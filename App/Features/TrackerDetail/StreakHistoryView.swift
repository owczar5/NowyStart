import SwiftUI
import SobrietyCore

/// Section displaying streak statistics and past series history.
public struct StreakHistoryView: View {
    public let currentStart: Date
    public let relapses: [Relapse]

    public init(currentStart: Date, relapses: [Relapse]) {
        self.currentStart = currentStart
        self.relapses = relapses
    }

    public var body: some View {
        let summary = StreakCalculator.calculate(
            currentStart: currentStart,
            relapses: relapses,
            now: Date()
        )

        VStack(alignment: .leading, spacing: 14) {
            Text("Historia serii")
                .font(.headline)
                .foregroundStyle(.primary)

            HStack(spacing: 12) {
                statBox(title: "Najdłuższa seria", value: "\(summary.longestStreakWholeDays) d")
                statBox(title: "Średnia seria", value: String(format: "%.1f d", summary.averageStreakDays))
                statBox(title: "Nowe starty", value: "\(summary.restartCount)")
            }

            if !relapses.isEmpty {
                VStack(spacing: 8) {
                    ForEach(relapses.sorted(by: { $0.restartedAt > $1.restartedAt })) { relapse in
                        let pastSec = max(0.0, relapse.restartedAt.timeIntervalSince(relapse.previousStart))
                        let pastDays = Int(pastSec / 86_400.0)

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Seria: \(pastDays) \(PluralHelper.day.word(for: pastDays))")
                                    .font(.subheadline.weight(.medium))
                                Spacer()
                                Text(relapse.restartedAt.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            if let note = relapse.note, !note.isEmpty {
                                Text(note)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            if !relapse.triggers.isEmpty {
                                HStack(spacing: 4) {
                                    ForEach(relapse.triggers, id: \.self) { trigger in
                                        Text(trigger)
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color(.tertiarySystemGroupedBackground))
                                            .clipShape(Capsule())
                                    }
                                }
                                .padding(.top, 2)
                            }
                        }
                        .padding(12)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
    }

    private func statBox(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.bold))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
