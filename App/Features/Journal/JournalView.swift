import SwiftUI
import SwiftData
import SobrietyCore

/// Root view for the Journal tab displaying daily check-ins, trends, and entry history.
public struct JournalView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \CheckIn.date, order: .reverse)
    private var checkIns: [CheckIn]

    @State private var isShowingEditor = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    streakHeaderView
                    newEntryButton
                    JournalChartView(checkIns: checkIns)
                    JournalHeatmapView(checkIns: checkIns)
                    recentEntriesSection
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Dziennik")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingEditor = true
                    } label: {
                        Label("Dodaj wpis", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingEditor) {
                CheckInEditorView()
            }
        }
    }

    private var streakHeaderView: some View {
        let streak = CheckInStats.checkInStreak(checkIns: checkIns)

        return HStack(spacing: 14) {
            Image(systemName: "calendar.badge.checkmark")
                .font(.title)
                .foregroundStyle(AppTheme.warmAccent)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(streak) \(PluralHelper.day.word(for: streak)) z rzędu z wpisem")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(streak > 0 ? "Regularne notowanie wzmacnia uważność i spokój." : "Zacznij od dzisiejszego wpisu.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var newEntryButton: some View {
        Button {
            isShowingEditor = true
        } label: {
            HStack {
                Image(systemName: "square.and.pencil")
                Text("Zapisz dzisiejszy nastrój i ochotę")
                    .fontWeight(.semibold)
            }
            .font(.subheadline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(AppTheme.primaryNavy)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var recentEntriesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ostatnie wpisy")
                .font(.headline)
                .foregroundStyle(.primary)

            if checkIns.isEmpty {
                Text("Brak zapisanych wpisów. Kliknij powyższy przycisk, aby dodać pierwszy wpis.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(checkIns.prefix(15)) { entry in
                    entryRow(entry)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func entryRow(_ entry: CheckIn) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)

                Spacer()

                HStack(spacing: 12) {
                    Text("Nastrój: \(entry.mood)/5")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.blue)

                    Text("Ochota: \(entry.craving)/10")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AppTheme.warmAccent)
                }
            }

            if let note = entry.note, !note.isEmpty {
                Text(note)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }

            if !entry.triggers.isEmpty {
                FlowLayout(spacing: 4) {
                    ForEach(entry.triggers, id: \.self) { trigger in
                        Text(trigger)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(.tertiarySystemGroupedBackground))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
