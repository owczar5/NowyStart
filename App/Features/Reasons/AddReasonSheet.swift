import SwiftUI
import SwiftData

/// Sheet for adding a new personal reason or motivation for staying sober.
public struct AddReasonSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(filter: #Predicate<Tracker> { !$0.isArchived })
    private var activeTrackers: [Tracker]

    @State private var text: String = ""
    @State private var selectedTrackerID: UUID?

    public init(preselectedTrackerID: UUID? = nil) {
        if let preselectedTrackerID {
            self._selectedTrackerID = State(initialValue: preselectedTrackerID)
        }
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section("Dlaczego podejmujesz ten krok?") {
                    TextField("Wpisz swój powód...", text: $text, axis: .vertical)
                        .lineLimit(3...5)
                }

                Section("Powiązany licznik") {
                    Picker("Licznik", selection: $selectedTrackerID) {
                        Text("Powód ogólny").tag(UUID?.none)
                        ForEach(activeTrackers) { tracker in
                            Text(tracker.customName ?? tracker.substanceKind.localizedTitleKey)
                                .tag(UUID?.some(tracker.id))
                        }
                    }
                }
            }
            .navigationTitle("Dodaj powód")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Anuluj") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Zapisz") { save() }
                        .font(.headline)
                        .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let reason = Reason(
            text: trimmed,
            trackerID: selectedTrackerID
        )
        modelContext.insert(reason)
        dismiss()
    }
}
