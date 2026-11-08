import Foundation
import SwiftData
import SobrietyCore

/// SwiftData persistent entity recording a restart event ("Nowy start").
/// Preserves past streak history permanently without deleting previous achievements.
@Model
public final class Relapse: RelapseRecord {
    public var id: UUID = UUID()
    public var trackerID: UUID = UUID()
    public var previousStart: Date = Date()
    public var restartedAt: Date = Date()
    public var note: String?
    public var triggers: [String] = []

    public var tracker: Tracker?

    public init(
        id: UUID = UUID(),
        trackerID: UUID,
        previousStart: Date,
        restartedAt: Date = Date(),
        note: String? = nil,
        triggers: [String] = []
    ) {
        self.id = id
        self.trackerID = trackerID
        self.previousStart = previousStart
        self.restartedAt = restartedAt
        self.note = note
        self.triggers = triggers
    }
}
