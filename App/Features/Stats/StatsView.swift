import SwiftUI
import SwiftData
import SobrietyCore

/// Statistics dashboard summarizing achievements, streaks, savings, and journal consistency.
public struct StatsView: View {
    @Query private var trackers: [Tracker]
    @Query private var checkIns: [CheckIn]

    public init() {}

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    overviewGrid
                    perTrackerBreakdownSection
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Statystyki")
        }
    }

    private var overviewGrid: some View {
        let longestDays = calculateLongestOverallStreak()
        let currentDays = calculateCurrentOverallStreak()
        let totalRestarts = trackers.reduce(0) { $0 + $1.relapses.count }
        let totalSavings = calculateTotalSavings()
        let totalLoggedDays = Set(checkIns.map { Calendar.current.startOfDay(for: $0.date) }).count
        let totalMilestones = calculateTotalMilestonesReached()

        return LazyVGrid(columns: columns, spacing: 12) {
            StatCardView(
                title: "Najdłuższa seria",
                value: "\(longestDays) d",
                subtitle: PluralHelper.day.word(for: longestDays),
                systemImage: "trophy.fill",
                tintColor: AppTheme.warmAccent
            )

            StatCardView(
                title: "Aktualna seria",
                value: "\(currentDays) d",
                subtitle: "w aktywnym liczniku",
                systemImage: "flame.fill",
                tintColor: Color.blue
            )

            StatCardView(
                title: "Nowe starty",
                value: "\(totalRestarts)",
                subtitle: "zachowane doświadczenia",
                systemImage: "arrow.triangle.2.circlepath",
                tintColor: Color.indigo
            )

            StatCardView(
                title: "Łączne oszczędności",
                value: String(format: "%.0f zł", NSDecimalNumber(decimal: totalSavings).doubleValue),
                subtitle: "na podstawie deklaracji",
                systemImage: "banknote.fill",
                tintColor: Color.green
            )

            StatCardView(
                title: "Dni z wpisem",
                value: "\(totalLoggedDays)",
                subtitle: "uważności w dzienniku",
                systemImage: "book.closed.fill",
                tintColor: Color.teal
            )

            StatCardView(
                title: "Zdobyte cele",
                value: "\(totalMilestones)",
                subtitle: "kamieni milowych",
                systemImage: "checkmark.seal.fill",
                tintColor: AppTheme.warmAccent
            )
        }
    }

    private var perTrackerBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Aktywne liczniki")
                .font(.headline)
                .foregroundStyle(.primary)

            if trackers.isEmpty {
                Text("Brak liczników do wyświetlenia statystyk.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(trackers.filter { !$0.isArchived }) { tracker in
                    let summary = StreakCalculator.calculate(
                        currentStart: tracker.startDate,
                        relapses: tracker.relapses,
                        now: Date()
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(TrackerDisplayHelper.displayName(for: tracker, discreet: false))
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            Text("\(summary.currentStreakWholeDays) d")
                                .font(.subheadline.bold())
                                .monospacedDigit()
                        }

                        HStack {
                            Text("Najdłuższa: \(summary.longestStreakWholeDays) d")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("Restartów: \(summary.restartCount)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(12)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }

    private func calculateLongestOverallStreak() -> Int {
        var maxDays = 0
        for tracker in trackers {
            let summary = StreakCalculator.calculate(
                currentStart: tracker.startDate,
                relapses: tracker.relapses,
                now: Date()
            )
            if summary.longestStreakWholeDays > maxDays {
                maxDays = summary.longestStreakWholeDays
            }
        }
        return maxDays
    }

    private func calculateCurrentOverallStreak() -> Int {
        var maxDays = 0
        for tracker in trackers where !tracker.isArchived {
            let elapsed = max(0.0, Date().timeIntervalSince(tracker.startDate))
            let days = Int(elapsed / 86_400.0)
            if days > maxDays {
                maxDays = days
            }
        }
        return maxDays
    }

    private func calculateTotalSavings() -> Decimal {
        var total: Decimal = .zero
        let now = Date()
        for tracker in trackers where !tracker.isArchived {
            let elapsed = max(0.0, now.timeIntervalSince(tracker.startDate))
            if let saved = Savings.moneySaved(
                dailyUnits: tracker.dailyUnits,
                unitPrice: tracker.unitPrice,
                elapsedSeconds: elapsed
            ) {
                total += saved
            }
        }
        return total
    }

    private func calculateTotalMilestonesReached() -> Int {
        var count = 0
        let now = Date()
        for tracker in trackers {
            count += Milestones.achieved(start: tracker.startDate, now: now).count
        }
        return count
    }
}
