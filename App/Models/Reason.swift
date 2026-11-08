import Foundation
import SwiftData

/// SwiftData persistent entity representing a personal motivation or reason to stay sober.
@Model
public final class Reason {
    public var id: UUID = UUID()
    public var text: String = ""
    public var trackerID: UUID?
    public var createdAt: Date = Date()

    public init(
        id: UUID = UUID(),
        text: String,
        trackerID: UUID? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.text = text
        self.trackerID = trackerID
        self.createdAt = createdAt
    }
}
