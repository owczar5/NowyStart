import Foundation
import SwiftData
import SobrietyCore

/// SwiftData persistent entity recording a daily mood and craving check-in.
@Model
public final class CheckIn: CheckInRecord {
    public var id: UUID = UUID()
    public var date: Date = Date()
    public var mood: Int = 3
    public var craving: Int = 0
    public var triggers: [String] = []
    public var note: String?
    public var trackerID: UUID?

    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        mood: Int,
        craving: Int,
        triggers: [String] = [],
        note: String? = nil,
        trackerID: UUID? = nil
    ) {
        self.id = id
        self.date = date
        self.mood = max(1, min(5, mood))
        self.craving = max(0, min(10, craving))
        self.triggers = triggers
        self.note = note
        self.trackerID = trackerID
    }
}
