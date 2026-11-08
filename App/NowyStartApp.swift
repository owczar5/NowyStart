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

/// Primary root tab container.
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

            NavigationStack {
                PlaceholderView(title: "Dziennik", systemImage: "book.pages")
            }
            .tabItem {
                Label("Dziennik", systemImage: "book.pages")
            }
            .tag(1)

            NavigationStack {
                PlaceholderView(title: "SOS", systemImage: "heart.circle")
            }
            .tabItem {
                Label("SOS", systemImage: "heart.circle")
            }
            .tag(2)

            NavigationStack {
                PlaceholderView(title: "Statystyki", systemImage: "chart.line.uptrend.xyaxis")
            }
            .tabItem {
                Label("Statystyki", systemImage: "chart.line.uptrend.xyaxis")
            }
            .tag(3)

            NavigationStack {
                PlaceholderView(title: "Ustawienia", systemImage: "gearshape")
            }
            .tabItem {
                Label("Ustawienia", systemImage: "gearshape")
            }
            .tag(4)
        }
        .tint(AppTheme.warmAccent)
    }
}

/// Placeholder for upcoming feature tabs in subsequent phases.
private struct PlaceholderView: View {
    let title: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.warmAccent)

            Text(title)
                .font(.title2.bold())

            Text("Moduł przygotowywany w kolejnej fazie projektu.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .navigationTitle(title)
    }
}
