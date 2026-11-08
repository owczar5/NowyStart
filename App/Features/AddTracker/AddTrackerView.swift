import SwiftUI
import SwiftData
import SobrietyCore

/// Modal sheet for creating a new sobriety tracker with validation and medical disclaimers.
public struct AddTrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedKind: SubstanceKind = .alcohol
    @State private var customName: String = ""
    @State private var alias: String = ""
    @State private var startDate: Date = Date()
    @State private var dailyUnitsString: String = ""
    @State private var unitPriceString: String = ""
    @State private var initialReason: String = ""

    @State private var validationError: String?
    @State private var isShowingMedicalWarning = false
    @State private var isShowingHelpSheet = false

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                substanceSection
                nameAndAliasSection
                dateSection
                savingsSection
                motivationSection
            }
            .navigationTitle("Nowy licznik")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Anuluj") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Zapisz") { attemptSave() }
                        .font(.headline)
                        .disabled(!isValid)
                }
            }
            .sheet(isPresented: $isShowingMedicalWarning) {
                MedicalWarningSheet(
                    onConfirm: { performSave() },
                    onOpenHelp: { isShowingHelpSheet = true }
                )
            }
        }
    }

    private var isValid: Bool {
        validationError == nil && startDate <= Date()
    }

    private var substanceSection: some View {
        Section("Wybierz rodzaj") {
            SubstancePickerGrid(selectedKind: $selectedKind)
        }
    }

    private var nameAndAliasSection: some View {
        Section("Nazewnictwo") {
            TextField("Własna nazwa (opcjonalnie)", text: $customName)
            TextField("Dyskretny alias (np. Zdrowie)", text: $alias)
        }
    }

    private var dateSection: some View {
        Section("Początek abstynencji") {
            DatePicker(
                "Data i godzina",
                selection: $startDate,
                in: ...Date(),
                displayedComponents: [.date, .hourAndMinute]
            )
            .onChange(of: startDate) { _, newValue in
                validateDate(newValue)
            }

            HStack(spacing: 8) {
                quickDateChip(title: "Teraz") {
                    startDate = Date()
                }
                quickDateChip(title: "Dziś rano") {
                    let cal = Calendar.current
                    startDate = cal.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
                }
                quickDateChip(title: "Wczoraj") {
                    startDate = Date().addingTimeInterval(-86_400)
                }
            }
            .padding(.vertical, 4)

            if let error = validationError {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .accessibilityLabel("Błąd walidacji: \(error)")
            }
        }
    }

    private var savingsSection: some View {
        Section("Oszczędności (opcjonalnie)") {
            HStack {
                Text("Zużycie dziennie (\(selectedKind.defaultUnitLabel))")
                Spacer()
                TextField("np. 5", text: $dailyUnitsString)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
            HStack {
                Text("Cena za jednostkę (PLN)")
                Spacer()
                TextField("np. 12.50", text: $unitPriceString)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
            }
        }
    }

    private var motivationSection: some View {
        Section("Twój powód (opcjonalnie)") {
            TextField("Dlaczego podejmujesz ten krok?", text: $initialReason)
        }
    }

    private func quickDateChip(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.footnote.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(.tertiarySystemGroupedBackground))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func validateDate(_ date: Date) {
        do {
            try StartDateValidator.validate(start: date, now: Date(), calendar: .current)
            validationError = nil
        } catch {
            validationError = error.localizedDescription
        }
    }

    private func attemptSave() {
        validateDate(startDate)
        guard isValid else { return }

        if selectedKind.requiresMedicalWarning {
            isShowingMedicalWarning = true
        } else {
            performSave()
        }
    }

    private func performSave() {
        let dailyUnits = Double(dailyUnitsString.replacingOccurrences(of: ",", with: "."))
        let unitPrice: Decimal?
        if !unitPriceString.isEmpty,
           let decimalVal = Decimal(string: unitPriceString.replacingOccurrences(of: ",", with: ".")) {
            unitPrice = decimalVal
        } else {
            unitPrice = nil
        }

        let tracker = Tracker(
            substanceKind: selectedKind,
            customName: customName.trimmingCharacters(in: .whitespaces).isEmpty ? nil : customName,
            alias: alias.trimmingCharacters(in: .whitespaces).isEmpty ? nil : alias,
            startDate: startDate,
            dailyUnits: dailyUnits,
            unitPrice: unitPrice
        )

        modelContext.insert(tracker)

        let trimmedReason = initialReason.trimmingCharacters(in: .whitespaces)
        if !trimmedReason.isEmpty {
            let reason = Reason(text: trimmedReason, trackerID: tracker.id)
            modelContext.insert(reason)
        }

        dismiss()
    }
}
