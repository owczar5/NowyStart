import SwiftUI

/// Suggestions for grounding and substitution activities during intense cravings.
public struct ReplacementActivitiesView: View {
    private let activities = [
        ("drop.fill", "Wypij powoli szklankę chłodnej wody"),
        ("figure.walk", "Wyjdź na krótki spacer na świeże powietrze"),
        ("hand.raised.fill", "Umyj twarz chłodną wodą"),
        ("phone.fill", "Zadzwoń do zaufanej osoby lub napisz wiadomość"),
        ("music.note", "Włącz spokojną muzykę lub podcast"),
        ("pencil.and.outline", "Zapisz w notatce to, co teraz czujesz")
    ]

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Proste czynności zastępcze")
                .font(.headline)
                .foregroundStyle(.primary)

            VStack(spacing: 8) {
                ForEach(activities, id: \.1) { icon, text in
                    HStack(spacing: 12) {
                        Image(systemName: icon)
                            .font(.body)
                            .foregroundStyle(AppTheme.warmAccent)
                            .frame(width: 28)

                        Text(text)
                            .font(.subheadline)
                            .foregroundStyle(.primary)

                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
