import Foundation

/// The root envelope for exported and imported backup data.
public struct BackupFile: Codable, Equatable, Sendable {
    public static let currentSchemaVersion: Int = 1

    public let schemaVersion: Int
    public let exportedAt: Date
    public let trackers: [TrackerBackupDTO]
    public let relapses: [RelapseBackupDTO]
    public let checkIns: [CheckInBackupDTO]
    public let reasons: [ReasonBackupDTO]
    public let supportContacts: [SupportContactBackupDTO]?

    public init(
        schemaVersion: Int = BackupFile.currentSchemaVersion,
        exportedAt: Date = Date(),
        trackers: [TrackerBackupDTO] = [],
        relapses: [RelapseBackupDTO] = [],
        checkIns: [CheckInBackupDTO] = [],
        reasons: [ReasonBackupDTO] = [],
        supportContacts: [SupportContactBackupDTO]? = nil
    ) {
        self.schemaVersion = schemaVersion
        self.exportedAt = exportedAt
        self.trackers = trackers
        self.relapses = relapses
        self.checkIns = checkIns
        self.reasons = reasons
        self.supportContacts = supportContacts
    }

    /// Serializes this backup to UTF-8 formatted JSON data.
    public func exportData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(self)
    }

    /// Imports and validates backup data from raw JSON.
    /// - Parameters:
    ///   - data: Raw JSON data.
    ///   - now: Reference time for future date checks.
    /// - Returns: Validated `BackupFile`.
    public static func importAndValidate(
        from data: Data,
        now: Date = Date()
    ) throws -> BackupFile {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let file: BackupFile
        do {
            file = try decoder.decode(BackupFile.self, from: data)
        } catch {
            throw BackupError.corruptedJSON(error.localizedDescription)
        }

        try file.validate(now: now)
        return file
    }

    /// Validates business invariants, schema version, date ranges, and duplicate IDs.
    public func validate(now: Date = Date()) throws {
        guard schemaVersion == BackupFile.currentSchemaVersion else {
            throw BackupError.unsupportedSchemaVersion(schemaVersion)
        }

        // Allow up to 60 seconds tolerance for clock drift
        let maxAllowedDate = now.addingTimeInterval(60.0)

        if exportedAt > maxAllowedDate {
            throw BackupError.futureDate(entity: "BackupFile", id: UUID(), date: exportedAt)
        }

        // Check duplicate IDs and field constraints for trackers
        var trackerIDs = Set<UUID>()
        for tracker in trackers {
            if !trackerIDs.insert(tracker.id).inserted {
                throw BackupError.duplicateIDs(entity: "Tracker", id: tracker.id)
            }
            if tracker.startDate > maxAllowedDate {
                throw BackupError.futureDate(entity: "Tracker.startDate", id: tracker.id, date: tracker.startDate)
            }
            if tracker.createdAt > maxAllowedDate {
                throw BackupError.futureDate(entity: "Tracker.createdAt", id: tracker.id, date: tracker.createdAt)
            }
            if let units = tracker.dailyUnits, units < 0 {
                throw BackupError.invalidValue(entity: "Tracker", field: "dailyUnits", value: "\(units)")
            }
            if let price = tracker.unitPrice, price < 0 {
                throw BackupError.invalidValue(entity: "Tracker", field: "unitPrice", value: "\(price)")
            }
        }

        // Check duplicate IDs and field constraints for relapses
        var relapseIDs = Set<UUID>()
        for relapse in relapses {
            if !relapseIDs.insert(relapse.id).inserted {
                throw BackupError.duplicateIDs(entity: "Relapse", id: relapse.id)
            }
            if relapse.previousStart > maxAllowedDate {
                throw BackupError.futureDate(entity: "Relapse.previousStart", id: relapse.id, date: relapse.previousStart)
            }
            if relapse.restartedAt > maxAllowedDate {
                throw BackupError.futureDate(entity: "Relapse.restartedAt", id: relapse.id, date: relapse.restartedAt)
            }
        }

        // Check duplicate IDs and field constraints for checkIns
        var checkInIDs = Set<UUID>()
        for checkIn in checkIns {
            if !checkInIDs.insert(checkIn.id).inserted {
                throw BackupError.duplicateIDs(entity: "CheckIn", id: checkIn.id)
            }
            if checkIn.date > maxAllowedDate {
                throw BackupError.futureDate(entity: "CheckIn.date", id: checkIn.id, date: checkIn.date)
            }
            if checkIn.mood < 1 || checkIn.mood > 5 {
                throw BackupError.invalidValue(entity: "CheckIn", field: "mood", value: "\(checkIn.mood)")
            }
            if checkIn.craving < 0 || checkIn.craving > 10 {
                throw BackupError.invalidValue(entity: "CheckIn", field: "craving", value: "\(checkIn.craving)")
            }
        }

        // Check duplicate IDs for reasons
        var reasonIDs = Set<UUID>()
        for reason in reasons {
            if !reasonIDs.insert(reason.id).inserted {
                throw BackupError.duplicateIDs(entity: "Reason", id: reason.id)
            }
            if reason.createdAt > maxAllowedDate {
                throw BackupError.futureDate(entity: "Reason.createdAt", id: reason.id, date: reason.createdAt)
            }
        }

        // Check duplicate IDs for support contacts (if present)
        if let contacts = supportContacts {
            var contactIDs = Set<UUID>()
            for contact in contacts {
                if !contactIDs.insert(contact.id).inserted {
                    throw BackupError.duplicateIDs(entity: "SupportContact", id: contact.id)
                }
            }
        }
    }
}
