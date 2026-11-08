import SwiftUI
import SwiftData
import SobrietyCore

/// Supportive and compassionate restart sheet for recording a stumble ("Nowy start") without shame.
public struct RestartTrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    public let tracker: Tracker

    @State private var newStartDate: Date = Date()
    @State private var note: String = ""
    @State private var selectedTriggers: Set<String> = []
    @State private var customTriggerInput: String = ""

    private let commonTriggers = [
        "Stres", "Zmęczenie", "Presja otoczenia", "Kłótnia", "Samotność", "Nuda", "Dostępność substancji"
    ]

    public init(tracker: Tracker) {
        self.tracker = tracker
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    compassionHeader
                    longestStreakAnchor
                    newDateSection
                    triggersSection
                    noteSection
                    saveButton
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Nowy start")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Anuluj") { dismiss() }
                }
            }
        }
    }

    private var compassionHeader: some View {
        VStack(spacing: 10) {
            Image(systemName: "sun.max.fill")
                .font(.system(size: 44))
                .foregroundStyle(AppTheme.warmAccent)

            Text("Potknięcie nie kasuje twojej drogi.")
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            Text("Każdy dzień przeżyty w trzeźwości należy do Ciebie i jest Twoim trwałym kapitałem. Zaczynasz kolejną serię mądrzejszy o nowe doświadczenie.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 8)
    }

    private var longestStreakAnchor: some View {
        let streakSummary = StreakCalculator.calculate(
            currentStart: tracker.startDate,
            relapses: tracker.relapses,
            now: Date()
        )

        return HStack {
            Image(systemName: "trophy")
                .font(.headline)
                .foregroundStyle(AppTheme.warmAccent)

            Text("Twój stały punkt odniesienia: ")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Najdłuższa seria \(streakSummary.longestStreakWholeDays) \(PluralHelper.day.word(for: streakSummary.longestStreakWholeDays))")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.primary)

            Spacer()
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var newDateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Kiedy zaczynasz nową serię?")
                .font(.subheadline.weight(.semibold))

            DatePicker(
                "Nowy początek",
                selection: $newStartDate,
                in: ...Date(),
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
            .padding(12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var triggersSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Co wpłynęło na sytuację? (opcjonalnie)")
                .font(.subheadline.weight(.semibold))

            FlowLayout(spacing: 8) {
                ForEach(commonTriggers, id: \.self) { trigger in
                    let isSelected = selectedTriggers.contains(trigger)
                    Button {
                        if isSelected {
                            selectedTriggers.remove(trigger)
                        } else {
                            selectedTriggers.insert(trigger)
                        }
                    } label: {
                        Text(trigger)
                            .font(.caption.weight(isSelected ? .semibold : .regular))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(isSelected ? AppTheme.warmAccent : Color(.secondarySystemGroupedBackground))
                            .foregroundStyle(isSelected ? .white : .primary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Twoja notatka na przyszłość (opcjonalnie)")
                .font(.subheadline.weight(.semibold))

            TextField("Czego się nauczyłeś? Co pomoże następnym razem?", text: $note, axis: .vertical)
                .lineLimit(3...5)
                .padding(12)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var saveButton: some View {
        Button {
            saveRestart()
        } label: {
            Text("Zacznij kolejną serię")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.primaryNavy)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.top, 8)
    }

    private func saveRestart() {
        let relapse = Relapse(
            trackerID: tracker.id,
            previousStart: tracker.startDate,
            restartedAt: newStartDate,
            note: note.trimmingCharacters(in: .whitespaces).isEmpty ? nil : note,
            triggers: Array(selectedTriggers)
        )

        modelContext.insert(relapse)
        tracker.relapses.append(relapse)
        tracker.startDate = newStartDate

        dismiss()
    }
}
