import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

/// Post-SOS rating sheet recording post-session craving intensity to the journal.
public struct SOSCompletionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var ratedCraving: Int = 3
    @State private var personalNote: String = ""

    public let onFinished: () -> Void

    public init(onFinished: @escaping () -> Void) {
        self.onFinished = onFinished
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color(red: 22 / 255, green: 101 / 255, blue: 52 / 255))
                    .padding(.top, 20)

                VStack(spacing: 8) {
                    Text("Minęło 10 minut uważności")
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)

                    Text("Fala ochoty osiąga swój szczyt i naturalnie opada. Jak oceniasz jej siłę w tej chwili?")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }

                VStack(spacing: 12) {
                    Text("Aktualna ochota: \(ratedCraving) / 10")
                        .font(.headline)
                        .foregroundStyle(AppTheme.warmAccent)

                    Slider(value: Binding(
                        get: { Double(ratedCraving) },
                        set: { ratedCraving = Int($0) }
                    ), in: 0...10, step: 1)
                    .tint(AppTheme.warmAccent)
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 20)

                Spacer()

                Button {
                    saveAndClose()
                } label: {
                    Text("Zapisz w dzienniku i zakończ")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.primaryNavy)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                triggerHapticFeedback()
            }
        }
    }

    private func triggerHapticFeedback() {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        #endif
    }

    private func saveAndClose() {
        let entry = CheckIn(
            date: Date(),
            mood: 3,
            craving: ratedCraving,
            triggers: ["Sesja SOS"],
            note: "Wpis po ukończeniu 10-minutowego wsparcia SOS."
        )
        modelContext.insert(entry)
        onFinished()
        dismiss()
    }
}
