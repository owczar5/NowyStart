import SwiftUI
import Charts
import SobrietyCore

/// Swift Charts visualization tracking mood and craving trends over 7, 30, or 90 days.
public struct JournalChartView: View {
    public let checkIns: [CheckIn]

    @State private var selectedWindowDays: Int = 7

    public init(checkIns: [CheckIn]) {
        self.checkIns = checkIns
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Trendy nastroju i ochoty")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                Picker("Okno czasowe", selection: $selectedWindowDays) {
                    Text("7 dni").tag(7)
                    Text("30 dni").tag(30)
                    Text("90 dni").tag(90)
                }
                .pickerStyle(.segmented)
                .frame(width: 170)
            }

            let filtered = entriesInWindow(days: selectedWindowDays)

            if filtered.isEmpty {
                Text("Brak wpisów w wybranym okresie.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 180, alignment: .center)
            } else {
                chartContent(entries: filtered)
                legendView
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private func chartContent(entries: [CheckIn]) -> some View {
        Chart {
            ForEach(entries) { entry in
                // Mood Line (Scale 1..5)
                LineMark(
                    x: .value("Data", entry.date, unit: .day),
                    y: .value("Wartość", entry.mood),
                    series: .value("Seria", "Nastrój")
                )
                .foregroundStyle(Color.blue)
                .interpolationMethod(.monotone)

                PointMark(
                    x: .value("Data", entry.date, unit: .day),
                    y: .value("Wartość", entry.mood)
                )
                .foregroundStyle(Color.blue)

                // Craving Line (Scale 0..10)
                LineMark(
                    x: .value("Data", entry.date, unit: .day),
                    y: .value("Wartość", entry.craving),
                    series: .value("Seria", "Ochota")
                )
                .foregroundStyle(AppTheme.warmAccent)
                .interpolationMethod(.monotone)

                PointMark(
                    x: .value("Data", entry.date, unit: .day),
                    y: .value("Wartość", entry.craving)
                )
                .foregroundStyle(AppTheme.warmAccent)
            }
        }
        .chartYScale(domain: 0...10)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: min(5, entries.count))) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.day().month(.twoDigits))
            }
        }
        .chartYAxis {
            AxisMarks(values: [0, 2, 4, 6, 8, 10]) { value in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .frame(height: 190)
    }

    private var legendView: some View {
        HStack(spacing: 20) {
            HStack(spacing: 6) {
                Circle().fill(Color.blue).frame(width: 8, height: 8)
                Text("Nastrój (1 - 5)").font(.caption).foregroundStyle(.secondary)
            }
            HStack(spacing: 6) {
                Circle().fill(AppTheme.warmAccent).frame(width: 8, height: 8)
                Text("Ochota (0 - 10)").font(.caption).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 4)
    }

    private func entriesInWindow(days: Int) -> [CheckIn] {
        let cal = Calendar.current
        guard let windowStart = cal.date(byAdding: .day, value: -days, to: Date()) else {
            return []
        }
        return checkIns
            .filter { $0.date >= windowStart && $0.date <= Date() }
            .sorted(by: { $0.date < $1.date })
    }
}
