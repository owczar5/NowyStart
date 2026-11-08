import SwiftUI

/// Accessible metric card highlighting a statistical figure.
public struct StatCardView: View {
    public let title: String
    public let value: String
    public let subtitle: String?
    public let systemImage: String
    public let tintColor: Color

    public init(
        title: String,
        value: String,
        subtitle: String? = nil,
        systemImage: String,
        tintColor: Color = AppTheme.warmAccent
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.tintColor = tintColor
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: systemImage)
                    .font(.subheadline)
                    .foregroundStyle(tintColor)

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(value)
                .font(.title2.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(.primary)

            if let subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
