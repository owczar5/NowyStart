import SwiftUI
import SobrietyCore

/// Emergency and helpline screen presenting verified/unverified crisis contact numbers.
public struct HelpView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var catalog: ResourcesCatalog?
    @State private var loadError: String?

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    disclaimerBanner
                    contentSection
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Pomoc kryzysowa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Gotowe") { dismiss() }
                }
            }
            .onAppear {
                loadCatalog()
            }
        }
    }

    private var disclaimerBanner: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "cross.circle.fill")
                .font(.title2)
                .foregroundStyle(.red)

            VStack(alignment: .leading, spacing: 4) {
                Text("Ważna informacja")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.primary)

                Text(catalog?.disclaimer ?? "Ta aplikacja nie zastępuje pomocy medycznej ani terapii.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var contentSection: some View {
        if let catalog {
            ForEach(catalog.countries, id: \.countryCode) { country in
                VStack(alignment: .leading, spacing: 10) {
                    Text(country.countryName)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    ForEach(country.resources) { resource in
                        ResourceItemRow(item: resource)
                    }
                }
            }
        } else if let error = loadError {
            Text("Nie udało się załadować numerów pomocy: \(error)")
                .font(.footnote)
                .foregroundStyle(.red)
        } else {
            ProgressView()
        }
    }

    private func loadCatalog() {
        if let url = Bundle.main.url(forResource: "Resources", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let parsed = try? ResourcesCatalog.load(from: data) {
            self.catalog = parsed
            return
        }

        // Embedded fallback directly matching App/Resources/Resources.json
        let fallbackJSON = """
        {
          "version": 1,
          "countries": [
            {
              "countryCode": "PL",
              "countryName": "Polska",
              "resources": [
                {
                  "id": "pl-emergency-112",
                  "name": "Numer alarmowy",
                  "description": "Ogólny numer alarmowy w nagłych wypadkach i zagrożeniu życia.",
                  "phoneNumber": "112",
                  "verified": false
                },
                {
                  "id": "pl-crisis-116123",
                  "name": "Kryzys emocjonalny",
                  "description": "Telefon wsparcia emocjonalnego dla dorosłych w kryzysie.",
                  "phoneNumber": "116 123",
                  "verified": false
                },
                {
                  "id": "pl-drugs-800199990",
                  "name": "Telefon Zaufania – Narkotyki",
                  "description": "Ogólnopolski telefon zaufania w sprawie problemu narkomanii.",
                  "phoneNumber": "800 199 990",
                  "verified": false
                }
              ]
            }
          ],
          "disclaimer": "Ta aplikacja nie zastępuje pomocy medycznej ani terapii."
        }
        """

        if let data = fallbackJSON.data(using: .utf8),
           let parsed = try? ResourcesCatalog.load(from: data) {
            self.catalog = parsed
        } else {
            self.loadError = "Brak dostępnych danych kontaktów kryzysowych."
        }
    }
}
