import SwiftUI
import SwiftData
import SobrietyCore

/// Detailed dashboard view for an individual tracker.
public struct TrackerDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isDiscreetMode") private var isDiscreet: Bool = false

    @Bindable public var tracker: Tracker

    @State private var isShowingRestartSheet = false
    @State private var isShowingEditStartDate = false
    @State private var editedStartDate: Date = Date()
    @State private var isShowingDeleteConfirmation = false

    public init(tracker: Tracker) {
        self.tracker = tracker
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                LiveClockView(
                    startDate: tracker.startDate,
                    tintColor: AppTheme.color(for: tracker.colorToken)
                )

                restartActionButton

                SavingsCardView(
                    startDate: tracker.startDate,
                    dailyUnits: tracker.dailyUnits,
                    unitPrice: tracker.unitPrice,
                    unitLabel: tracker.unitLabel,
                    currencyCode: tracker.currencyCode
                )

                MilestoneListView(
                    startDate: tracker.startDate,
                    tintColor: AppTheme.color(for: tracker.colorToken)
                )

                StreakHistoryView(
                    currentStart: tracker.startDate,
                    relapses: tracker.relapses
                )
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(TrackerDisplayHelper.displayName(for: tracker, discreet: isDiscreet))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        editedStartDate = tracker.startDate
                        isShowingEditStartDate = true
                    } label: {
                        Label("Edytuj datę startu", systemImage: "pencil")
                    }

                    Button {
                        tracker.isArchived.toggle()
                        dismiss()
                    } label: {
                        Label(
                            tracker.isArchived ? "Przywróć z archiwum" : "Archiwizuj",
                            systemImage: tracker.isArchived ? "tray.and.arrow.up" : "archivebox"
                        )
                    }

                    Divider()

                    Button(role: .destructive) {
                        isShowingDeleteConfirmation = true
                    } label: {
                        Label("Usuń licznik", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isShowingRestartSheet) {
            RestartTrackerView(tracker: tracker)
        }
        .sheet(isPresented: $isShowingEditStartDate) {
            editStartDateSheet
        }
        .confirmationDialog(
            "Czy na pewno chcesz usunąć ten licznik?",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Usuń bezpowrotnie", role: .destructive) {
                modelContext.delete(tracker)
                dismiss()
            }
            Button("Anuluj", role: .cancel) {}
        } message: {
            Text("Wszystkie dane tego licznika oraz powiązane serie zostaną trwale usunięte.")
        }
    }

    private var restartActionButton: some View {
        Button {
            isShowingRestartSheet = true
        } label: {
            HStack {
                Image(systemName: "arrow.counterclockwise")
                Text("Nowy start (potknięcie)")
                    .fontWeight(.semibold)
            }
            .font(.subheadline)
            .foregroundStyle(AppTheme.warmAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(AppTheme.warmAccent.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var editStartDateSheet: some View {
        NavigationStack {
            Form {
                Section("Korekta daty") {
                    DatePicker(
                        "Data i godzina startu",
                        selection: $editedStartDate,
                        in: ...Date(),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
            }
            .navigationTitle("Zmień datę początkową")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Anuluj") { isShowingEditStartDate = false }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Zapisz") {
                        tracker.startDate = editedStartDate
                        isShowingEditStartDate = false
                    }
                    .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
