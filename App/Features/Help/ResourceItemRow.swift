import SwiftUI
import SobrietyCore

/// Row displaying a crisis helpline with an immediate dial button.
public struct ResourceItemRow: View {
    public let item: SupportResourceItem

    public init(item: SupportResourceItem) {
        self.item = item
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(item.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if let url = item.phoneURL {
                    Link(destination: url) {
                        HStack(spacing: 6) {
                            Image(systemName: "phone.fill")
                            Text("Zadzwoń")
                        }
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .clipShape(Capsule())
                    }
                }
            }

            HStack {
                Text(item.phoneNumber)
                    .font(.subheadline.monospacedDigit().weight(.semibold))
                    .foregroundStyle(.primary)

                Spacer()

                if !item.verified {
                    Text("Weryfikacja: niepotwierdzony")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
