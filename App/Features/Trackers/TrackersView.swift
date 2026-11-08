import SwiftUI
import SwiftData
import SobrietyCore

/// Main dashboard view listing all active sobriety trackers.
public struct TrackersView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("isDiscreetMode") private var isDiscreet: Bool = false

    @Query(
        filter: #Predicate<Tracker> { !$0.isArchived },
        sort: \.createdAt,
        order: .reverse
    )
    private var trackers: [Tracker]

    @State private var isPresentingAddSheet = false
    @State private var trackerToDelete: Tracker?
    @State private var isShowingDeleteConfirmation = false

    public init() {}

    public var body: some View {
        NavigationStack {
            Group {
                if trackers.isEmpty {
                    emptyStateView
                } else {
                    trackerListView
                }
            }
            .navigationTitle("Liczniki")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingAddSheet = true
                    } label: {
                        Label("Dodaj licznik", systemImage: "plus")
                    }
                    .accessibilityLabel("Dodaj nowy licznik")
                }
            }
            .sheet(isPresented: $isPresentingAddSheet) {
                AddTrackerView()
            }
            .confirmationDialog(
                "Czy na pewno chcesz usunąć ten licznik?",
                isPresented: $isShowingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Usuń licznik", role: .destructive) {
                    if let target = trackerToDelete {
                        modelContext.delete(target)
                        trackerToDelete = nil
                    }
                }
                Button("Anuluj", role: .cancel) {
                    trackerToDelete = nil
                }
            } message: {
                Text("Ta operacja bezpowrotnie usunie licznik i całą historię powiązanych serii.")
            }
        }
    }

    private var trackerListView: some View {
        List {
            ForEach(trackers) { tracker in
                NavigationLink(value: tracker.id) {
                    TrackerCardView(tracker: tracker, isDiscreet: isDiscreet)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowBackground(Color.clear)
                .swipeActions(edge: .leading) {
                    Button {
                        tracker.isArchived = true
                    } label: {
                        Label("Archiwizuj", systemImage: "archivebox")
                    }
                    .tint(.indigo)
                }
                .swipeActions(edge: .trailing, role: .destructive) {
                    Button {
                        trackerToDelete = tracker
                        isShowingDeleteConfirmation = true
                    } label: {
                        Label("Usuń", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
        .background(Color(.systemGroupedBackground))
        .navigationDestination(for: UUID.self) { trackerID in
            if let target = trackers.first(where: { $0.id == trackerID }) {
                TrackerDetailView(tracker: target)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 64))
                .foregroundStyle(AppTheme.warmAccent)
                .padding(.bottom, 8)

            Text("Brak aktywnych liczników")
                .font(.title2.bold())
                .foregroundStyle(.primary)

            Text("Każda podróż zaczyna się od pierwszego kroku. Dodaj swój licznik, by w spokojny i rzeczowy sposób śledzić czas.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button {
                isPresentingAddSheet = true
            } label: {
                Text("Dodaj pierwszy licznik")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppTheme.primaryNavy)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
            .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}
