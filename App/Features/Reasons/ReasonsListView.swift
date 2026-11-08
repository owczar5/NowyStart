import SwiftUI
import SwiftData

/// View managing user's personal list of motivations and reasons.
public struct ReasonsListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Reason.createdAt, order: .reverse)
    private var reasons: [Reason]

    @State private var isShowingAddSheet = false

    public init() {}

    public var body: some View {
        List {
            if reasons.isEmpty {
                VStack(spacing: 8) {
                    Text("Brak zapisanych powodów")
                        .font(.headline)
                    Text("Dodaj powody, dla których trzeźwość jest dla Ciebie ważna. Będą wyświetlane w chwilach pokusy.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)
                .listRowBackground(Color.clear)
            } else {
                ForEach(reasons) { reason in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(reason.text)
                            .font(.body)
                            .foregroundStyle(.primary)

                        Text(reason.createdAt.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        modelContext.delete(reasons[index])
                    }
                }
            }
        }
        .navigationTitle("Moje powody")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingAddSheet = true
                } label: {
                    Label("Dodaj powód", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingAddSheet) {
            AddReasonSheet()
        }
    }
}
