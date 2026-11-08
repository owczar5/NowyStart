import SwiftUI

/// Informational sheet presented before saving trackers for high-risk substances (alcohol, benzodiazepines, opioids).
public struct MedicalWarningSheet: View {
    public let onConfirm: () -> Void
    public let onOpenHelp: () -> Void
    @Environment(\.dismiss) private var dismiss

    public init(onConfirm: @escaping () -> Void, onOpenHelp: @escaping () -> Void) {
        self.onConfirm = onConfirm
        self.onOpenHelp = onOpenHelp
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "cross.case.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color(red: 225 / 255, green: 29 / 255, blue: 72 / 255))
                    .padding(.top, 24)

                Text("Ważna informacja o bezpieczeństwie")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text("Nagłe odstawienie niektórych substancji (zwłaszcza alkoholu, benzodiazepin i opioidów) może być niebezpieczne dla zdrowia i życia. Jeśli używałeś ich regularnie lub w dużych ilościach, skonsultuj się z lekarzem.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Text("Ta aplikacja jest narzędziem wspierającym organizację czasu i nawyków, nie stanowi porady medycznej ani diagnozy.")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        onConfirm()
                        dismiss()
                    } label: {
                        Text("Rozumiem i kontynuuję")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.primaryNavy)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        dismiss()
                        onOpenHelp()
                    } label: {
                        Text("Zobacz numery pomocowe")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.warmAccent)
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Anuluj") {
                        dismiss()
                    }
                }
            }
        }
    }
}
