import SwiftUI
import SobrietyCore

/// Selection grid for substances and habits supported by Nowy Start.
public struct SubstancePickerGrid: View {
    @Binding public var selectedKind: SubstanceKind

    public init(selectedKind: Binding<SubstanceKind>) {
        self._selectedKind = selectedKind
    }

    private let columns = [
        GridItem(.adaptive(minimum: 95), spacing: 12)
    ]

    public var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(SubstanceKind.allCases) { kind in
                let isSelected = kind == selectedKind
                Button {
                    selectedKind = kind
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: kind.systemSymbolName)
                            .font(.title2)
                            .foregroundStyle(isSelected ? .white : AppTheme.color(for: kind.colorToken))
                            .frame(width: 44, height: 44)
                            .background(
                                isSelected
                                ? AppTheme.color(for: kind.colorToken)
                                : AppTheme.color(for: kind.colorToken).opacity(0.12)
                            )
                            .clipShape(Circle())

                        Text(kind.localizedTitleKey)
                            .font(.caption)
                            .fontWeight(isSelected ? .semibold : .regular)
                            .foregroundStyle(isSelected ? .primary : .secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity, minHeight: 90)
                    .padding(8)
                    .background(Color(.secondarySystemGroupedBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? AppTheme.color(for: kind.colorToken) : Color.clear,
                                lineWidth: 2
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(kind.localizedTitleKey)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }
}
