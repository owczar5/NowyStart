import SwiftUI
import SobrietyCore

/// Card presenting estimated units avoided and total money saved.
public struct SavingsCardView: View {
    public let startDate: Date
    public let dailyUnits: Double?
    public let unitPrice: Decimal?
    public let unitLabel: String
    public let currencyCode: String

    public init(
        startDate: Date,
        dailyUnits: Double?,
        unitPrice: Decimal?,
        unitLabel: String,
        currencyCode: String
    ) {
        self.startDate = startDate
        self.dailyUnits = dailyUnits
        self.unitPrice = unitPrice
        self.unitLabel = unitLabel
        self.currencyCode = currencyCode
    }

    public var body: some View {
        TimelineView(.periodic(from: .now, by: 60.0)) { timeline in
            let elapsed = max(0.0, timeline.date.timeIntervalSince(startDate))
            let avoided = Savings.unitsAvoided(dailyUnits: dailyUnits, elapsedSeconds: elapsed)
            let saved = Savings.moneySaved(dailyUnits: dailyUnits, unitPrice: unitPrice, elapsedSeconds: elapsed)

            if avoided != nil || saved != nil {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Oszczędności")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    HStack(spacing: 12) {
                        if let units = avoided {
                            metricBox(
                                title: "Ominięte",
                                value: String(format: "%.1f", units),
                                subtitle: unitLabel
                            )
                        }

                        if let money = saved {
                            metricBox(
                                title: "Zaoszczędzone",
                                value: String(format: "%.2f", NSDecimalNumber(decimal: money).doubleValue),
                                subtitle: currencyCode
                            )
                        }
                    }
                }
            }
        }
    }

    private func metricBox(title: String, value: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.title3.weight(.bold))
                    .monospacedDigit()
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
