import SwiftUI
import SobrietyCore

/// Monthly calendar heatmap marking days with recorded check-ins.
public struct JournalHeatmapView: View {
    public let checkIns: [CheckIn]

    @State private var currentMonthDate: Date = Date()
    private let calendar: Calendar = .current

    public init(checkIns: [CheckIn]) {
        self.checkIns = checkIns
    }

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(currentMonthDate.formatted(.dateTime.year().month(.wide)).capitalized)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                HStack(spacing: 8) {
                    Button {
                        changeMonth(by: -1)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.subheadline)
                    }
                    Button {
                        changeMonth(by: 1)
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                    }
                }
                .foregroundStyle(.secondary)
            }

            weekdayHeaders

            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(daysForMonth(), id: \.self) { date in
                    if let date {
                        dayCell(for: date)
                    } else {
                        Color.clear.frame(height: 32)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var weekdayHeaders: some View {
        HStack {
            ForEach(calendar.veryShortWeekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func dayCell(for date: Date) -> some View {
        let hasEntry = loggedDaysSet.contains(calendar.startOfDay(for: date))
        let isToday = calendar.isDateInToday(date)
        let dayNumber = calendar.component(.day, from: date)

        return ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(hasEntry ? AppTheme.warmAccent : Color(.tertiarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isToday ? AppTheme.primaryNavy : Color.clear, lineWidth: 1.5)
                )

            Text("\(dayNumber)")
                .font(.caption2.weight(hasEntry ? .bold : .regular))
                .foregroundStyle(hasEntry ? .white : .primary)
        }
        .frame(height: 32)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(dayNumber) \(currentMonthDate.formatted(.dateTime.month())): \(hasEntry ? "wpis obecny" : "brak wpisu")")
    }

    private var loggedDaysSet: Set<Date> {
        Set(checkIns.map { calendar.startOfDay(for: $0.date) })
    }

    private func changeMonth(by amount: Int) {
        if let newDate = calendar.date(byAdding: .month, value: amount, to: currentMonthDate) {
            currentMonthDate = newDate
        }
    }

    private func daysForMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonthDate),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }

        var days: [Date?] = []
        var current = monthFirstWeek.start

        while current < monthInterval.end || days.count % 7 != 0 {
            if current >= monthInterval.start && current < monthInterval.end {
                days.append(current)
            } else if current < monthInterval.start {
                days.append(nil)
            } else {
                break
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }

        return days
    }
}
