import SwiftUI
import SwiftData

/// Sheet for adding a new trusted support contact stored strictly on-device.
public struct AddContactSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var phone: String = ""

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section("Dane osoby zaufanej") {
                    TextField("Imię lub relacja (np. Brat, Przyjaciel)", text: $name)
                    TextField("Numer telefonu", text: $phone)
                        .keyboardType(.phonePad)
                }

                Section {
                    Text("Kontakt zostanie zapisany wyłącznie na tym urządzeniu i posłuży do szybkiego połączenia w chwilach kryzysu.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Nowy kontakt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Anuluj") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Zapisz") { save() }
                        .font(.headline)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || phone.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedPhone = phone.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty, !trimmedPhone.isEmpty else { return }

        let contact = SupportContact(name: trimmedName, phone: trimmedPhone)
        modelContext.insert(contact)
        dismiss()
    }
}
