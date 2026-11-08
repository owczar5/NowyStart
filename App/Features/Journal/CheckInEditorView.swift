import SwiftUI
import SwiftData
import SobrietyCore

/// Modal editor for creating or updating a daily check-in entry.
public struct CheckInEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(filter: #Predicate<Tracker> { !$0.isArchived })
    private var activeTrackers: [Tracker]

    @State private var mood: Int = 3
    @State private var craving: Int = 2
    @State private var note: String = ""
    @State private var selectedTriggers: Set<String> = []
    @State private var customTrigger: String = ""
    @State private var selectedTrackerID: UUID?

    private let moodDescriptions: [Int: String] = [
        1: "Bardzo trudny",
        2: "Obniżony",
        3: "Spokojny / neutralny",
        4: "Dobry",
        5: "Bardzo dobry"
    ]

    private let commonTriggers = [
        "Stres", "Zmęczenie", "Nuda", "Samotność", "Presja otoczenia", "Złość", "Impreza"
    ]

    public init(initialCraving: Int? = nil, trackerID: UUID? = nil) {
        if let initialCraving {
            self._craving = State(initialValue: initialCraving)
        }
        if let trackerID {
            self._selectedTrackerID = State(initialValue: trackerID)
        }
    }

    public var body: some View {
        NavigationStack {
            Form {
                moodSection
                cravingSection
                triggersSection
                trackerAssociationSection
                noteSection
            }
            .navigationTitle("Dzienny wpis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Anuluj") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Zapisz") { saveCheckIn() }
                        .font(.headline)
                }
            }
        }
    }

    private var moodSection: some View {
        Section("Nastrój (1 - 5)") {
            Picker("Nastrój", selection: $mood) {
                ForEach(1...5, id: \.self) { level in
                    Text("\(level) - \(moodDescriptions[level] ?? "")")
                        .tag(level)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var cravingSection: some View {
        Section("Intensywność ochoty: \(craving) / 10") {
            Slider(value: Binding(
                get: { Double(craving) },
                set: { craving = Int($0) }
            ), in: 0...10, step: 1)
            .tint(AppTheme.warmAccent)
            .accessibilityLabel("Intensywność ochoty")
            .accessibilityValue("\(craving) na 10")

            HStack {
                Text("0 (Brak ochoty)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("10 (Bardzo silna)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var triggersSection: some View {
        Section("Wyzwalacze") {
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
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(isSelected ? AppTheme.warmAccent : Color(.tertiarySystemGroupedBackground))
                            .foregroundStyle(isSelected ? .white : .primary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)

            HStack {
                TextField("Wpisz inny wyzwalacz", text: $customTrigger)
                if !customTrigger.trimmingCharacters(in: .whitespaces).isEmpty {
                    Button("Dodaj") {
                        let trimmed = customTrigger.trimmingCharacters(in: .whitespaces)
                        selectedTriggers.insert(trimmed)
                        customTrigger = ""
                    }
                }
            }
        }
    }

    private var trackerAssociationSection: some View {
        Section("Powiązany licznik") {
            Picker("Licznik", selection: $selectedTrackerID) {
                Text("Wpis ogólny (brak powiązania)").tag(UUID?.none)
                ForEach(activeTrackers) { tracker in
                    Text(TrackerDisplayHelper.displayName(for: tracker, discreet: false))
                        .tag(UUID?.some(tracker.id))
                }
            }
        }
    }

    private var noteSection: some View {
        Section("Notatka") {
            TextField("Twoje refleksje, co dziś pomagało zachować spokój...", text: $note, axis: .vertical)
                .lineLimit(3...5)
        }
    }

    private func saveCheckIn() {
        let checkIn = CheckIn(
            date: Date(),
            mood: mood,
            craving: craving,
            triggers: Array(selectedTriggers),
            note: note.trimmingCharacters(in: .whitespaces).isEmpty ? nil : note,
            trackerID: selectedTrackerID
        )
        modelContext.insert(checkIn)
        dismiss()
    }
}
