import Foundation

/// Errors that can occur during backup export and import validation.
public enum BackupError: Error, Equatable, LocalizedError, Sendable {
    case unsupportedSchemaVersion(Int)
    case corruptedJSON(String)
    case duplicateIDs(entity: String, id: UUID)
    case futureDate(entity: String, id: UUID, date: Date)
    case invalidValue(entity: String, field: String, value: String)

    public var errorDescription: String? {
        switch self {
        case .unsupportedSchemaVersion(let version):
            return "Nieobsługiwana wersja schematu kopii zapasowej (\(version)). Aplikacja obsługuje wersję 1."
        case .corruptedJSON(let detail):
            return "Plik kopii zapasowej jest uszkodzony lub ma nieprawidłowy format JSON: \(detail)"
        case .duplicateIDs(let entity, let id):
            return "Wykryto zduplikowany identyfikator \(id.uuidString) w sekcji \(entity)."
        case .futureDate(let entity, let id, _):
            return "Data w sekcji \(entity) (ID: \(id.uuidString)) znajduje się w przyszłości."
        case .invalidValue(let entity, let field, let value):
            return "Nieprawidłowa wartość pola '\(field)' w sekcji \(entity): \(value)."
        }
    }
}

public struct TrackerBackupDTO: Codable, Equatable, Sendable {
    public let id: UUID
    public let substanceKind: String
    public let customName: String?
    public let alias: String?
    public let startDate: Date
    public let createdAt: Date
    public let dailyUnits: Double?
    public let unitPrice: Decimal?
    public let currencyCode: String
    public let unitLabel: String
    public let colorToken: String
    public let isArchived: Bool

    public init(
        id: UUID,
        substanceKind: String,
        customName: String? = nil,
        alias: String? = nil,
        startDate: Date,
        createdAt: Date,
        dailyUnits: Double? = nil,
        unitPrice: Decimal? = nil,
        currencyCode: String,
        unitLabel: String,
        colorToken: String,
        isArchived: Bool = false
    ) {
        self.id = id
        self.substanceKind = substanceKind
        self.customName = customName
        self.alias = alias
        self.startDate = startDate
        self.createdAt = createdAt
        self.dailyUnits = dailyUnits
        self.unitPrice = unitPrice
        self.currencyCode = currencyCode
        self.unitLabel = unitLabel
        self.colorToken = colorToken
        self.isArchived = isArchived
    }
}

public struct RelapseBackupDTO: Codable, Equatable, Sendable {
    public let id: UUID
    public let trackerID: UUID
    public let previousStart: Date
    public let restartedAt: Date
    public let note: String?
    public let triggers: [String]

    public init(
        id: UUID,
        trackerID: UUID,
        previousStart: Date,
        restartedAt: Date,
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

public struct CheckInBackupDTO: Codable, Equatable, Sendable {
    public let id: UUID
    public let date: Date
    public let mood: Int
    public let craving: Int
    public let triggers: [String]
    public let note: String?
    public let trackerID: UUID?

    public init(
        id: UUID,
        date: Date,
        mood: Int,
        craving: Int,
        triggers: [String] = [],
        note: String? = nil,
        trackerID: UUID? = nil
    ) {
        self.id = id
        self.date = date
        self.mood = mood
        self.craving = craving
        self.triggers = triggers
        self.note = note
        self.trackerID = trackerID
    }
}

public struct ReasonBackupDTO: Codable, Equatable, Sendable {
    public let id: UUID
    public let text: String
    public let trackerID: UUID?
    public let createdAt: Date

    public init(id: UUID, text: String, trackerID: UUID? = nil, createdAt: Date) {
        self.id = id
        self.text = text
        self.trackerID = trackerID
        self.createdAt = createdAt
    }
}

public struct SupportContactBackupDTO: Codable, Equatable, Sendable {
    public let id: UUID
    public let name: String
    public let phone: String

    public init(id: UUID, name: String, phone: String) {
        self.id = id
        self.name = name
        self.phone = phone
    }
}
