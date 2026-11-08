import SwiftUI
import SwiftData

/// Application entry point configuring SwiftData shared App Group container and primary tabs.
@main
public struct NowyStartApp: App {
    private let container: ModelContainer

    public init() {
        self.container = DataContainer.makeSharedContainer()
    }

    public var body: some Scene {
        WindowGroup {
            MainTabView()
                .modelContainer(container)
        }
    }
}

/// Primary root tab container for Nowy Start.
public struct MainTabView: View {
    @State private var selectedTab: Int = 0

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            TrackersView()
                .tabItem {
                    Label("Liczniki", systemImage: "clock.arrow.circlepath")
                }
                .tag(0)

            JournalView()
                .tabItem {
                    Label("Dziennik", systemImage: "book.pages")
                }
                .tag(1)

            SOSView()
                .tabItem {
                    Label("SOS", systemImage: "heart.circle")
                }
                .tag(2)

            StatsView()
                .tabItem {
                    Label("Statystyki", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(3)

            NavigationStack {
                SettingsPlaceholderView()
            }
            .tabItem {
                Label("Ustawienia", systemImage: "gearshape")
            }
            .tag(4)
        }
        .tint(AppTheme.warmAccent)
    }
}

/// Placeholder for Settings tab implemented in Phase 4.
private struct SettingsPlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "gearshape")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.warmAccent)

            Text("Ustawienia")
                .font(.title2.bold())

            Text("Moduł powiadomień, blokady Face ID/kodu, eksportu/importu i trybu dyskretnego.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .navigationTitle("Ustawienia")
    }
}
