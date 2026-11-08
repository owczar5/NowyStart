import SwiftUI
import SwiftData

/// View managing trusted personal contacts available for immediate calling during cravings.
public struct SupportContactsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \SupportContact.name)
    private var contacts: [SupportContact]

    @State private var isShowingAddSheet = false

    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Kontakty są zapisane wyłącznie lokalnie w pamięci urządzenia. Kliknięcie nawiązuje bezpośrednie połączenie telefoniczne.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if contacts.isEmpty {
                    VStack(spacing: 8) {
                        Text("Brak kontaktów wsparcia")
                            .font(.headline)
                        Text("Warto dodać przynajmniej jedną bliską osobę, do której możesz zadzwonić, gdy pojawi się pokusa.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(contacts) { contact in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(contact.name)
                                    .font(.headline)
                                Text(contact.phone)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if let url = contact.callURL {
                                Link(destination: url) {
                                    Image(systemName: "phone.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(Color.green)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            modelContext.delete(contacts[index])
                        }
                    }
                }
            }
            .navigationTitle("Kontakty wsparcia")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Zamknij") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAddSheet = true
                    } label: {
                        Label("Dodaj kontakt", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                AddContactSheet()
            }
        }
    }
}
