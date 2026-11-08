import SwiftUI
import SwiftData

/// Dedicated SOS urgency screen guiding users through craving spikes.
public struct SOSView: View {
    @Query private var reasons: [Reason]
    @Query private var supportContacts: [SupportContact]

    @State private var remainingSeconds: Int = 600
    @State private var isTimerActive: Bool = true
    @State private var selectedReasonText: String?
    @State private var isShowingHelpSheet: Bool = false
    @State private var isShowingCompletionSheet: Bool = false
    @State private var isShowingContactsSheet: Bool = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    timerHeaderView
                    randomMotivationBanner
                    BreathingExerciseView()
                    ReplacementActivitiesView()
                    actionButtonsSection
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("SOS - Mam ochotę")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Zakończ") {
                        isShowingCompletionSheet = true
                    }
                    .font(.subheadline.bold())
                }
            }
            .sheet(isPresented: $isShowingHelpSheet) {
                HelpView()
            }
            .sheet(isPresented: $isShowingCompletionSheet) {
                SOSCompletionView {
                    remainingSeconds = 600
                }
            }
            .sheet(isPresented: $isShowingContactsSheet) {
                SupportContactsListView()
            }
            .onAppear {
                pickRandomReason()
            }
            .onReceive(timer) { _ in
                guard isTimerActive else { return }
                if remainingSeconds > 0 {
                    remainingSeconds -= 1
                } else {
                    isTimerActive = false
                    isShowingCompletionSheet = true
                }
            }
        }
    }

    private var timerHeaderView: some View {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60

        return VStack(spacing: 6) {
            Text("Fala ochoty trwa zazwyczaj do 10 minut")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text(String(format: "%02d:%02d", minutes, seconds))
                .font(.system(size: 52, weight: .bold, design: .monospaced))
                .monospacedDigit()
                .foregroundStyle(AppTheme.warmAccent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var randomMotivationBanner: some View {
        Group {
            if let reason = selectedReasonText {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "quote.opening")
                        .font(.title3)
                        .foregroundStyle(AppTheme.warmAccent)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Twój powód:")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(reason)
                            .font(.subheadline.italic())
                            .foregroundStyle(.primary)
                    }

                    Spacer()
                }
                .padding(14)
                .background(AppTheme.warmAccent.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            if let contact = supportContacts.first, let url = contact.callURL {
                Link(destination: url) {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text("Zadzwoń do: \(contact.name)")
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            } else {
                Button {
                    isShowingContactsSheet = true
                } label: {
                    HStack {
                        Image(systemName: "person.crop.circle.badge.plus")
                        Text("Dodaj bliską osobę do szybkiego kontaktu")
                    }
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.primaryNavy)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            Button {
                isShowingHelpSheet = true
            } label: {
                HStack {
                    Image(systemName: "cross.fill")
                    Text("Numery kryzysowe i pomoc medyczna")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func pickRandomReason() {
        if let randomReason = reasons.randomElement() {
            selectedReasonText = randomReason.text
        }
    }
}
