import Foundation
import SwiftData

/// Shared storage and container setup for SwiftData across main application and WidgetKit extension.
public enum DataContainer {
    public static let appGroupIdentifier = "group.pl.nowystart.app"
    public static let databaseFileName = "NowyStart.store"

    /// Builds a ModelContainer configured for the shared App Group container.
    /// Falls back to local Application Support if the App Group container is unavailable.
    public static func makeSharedContainer(inMemory: Bool = false) -> ModelContainer {
        let schema = Schema([
            Tracker.self,
            Relapse.self,
            CheckIn.self,
            Reason.self,
            SupportContact.self
        ])

        if inMemory {
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                return try ModelContainer(for: schema, configurations: config)
            } catch {
                fatalError("Failed to instantiate in-memory ModelContainer: \(error)")
            }
        }

        let storeURL: URL
        if let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) {
            storeURL = containerURL.appendingPathComponent(databaseFileName)
        } else {
            // Fallback for sandboxed previews or testing environments
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            try? FileManager.default.createDirectory(at: appSupport, withIntermediateDirectories: true)
            storeURL = appSupport.appendingPathComponent(databaseFileName)
        }

        let config = ModelConfiguration(
            schema: schema,
            url: storeURL,
            allowsSave: true
        )

        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            // If existing store schema is incompatible during development, attempt fallback
            let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                return try ModelContainer(for: schema, configurations: fallbackConfig)
            } catch {
                fatalError("Failed to initialize SwiftData ModelContainer: \(error)")
            }
        }
    }
}
