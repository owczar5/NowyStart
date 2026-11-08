import XCTest
@testable import SobrietyCore

final class BackupTests: XCTestCase {
    /// Test 9: Round trip export -> import yields identical data.
    func testBackupRoundTrip() throws {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let trackerID = UUID()
        let relapseID = UUID()
        let checkInID = UUID()
        let reasonID = UUID()
        let contactID = UUID()

        let tracker = TrackerBackupDTO(
            id: trackerID,
            substanceKind: "alcohol",
            customName: "Mój tracker",
            alias: "Zdrowie",
            startDate: now.addingTimeInterval(-86400 * 30),
            createdAt: now.addingTimeInterval(-86400 * 30),
            dailyUnits: 4.0,
            unitPrice: Decimal(string: "15.50"),
            currencyCode: "PLN",
            unitLabel: "drinki",
            colorToken: "substanceTeal",
            isArchived: false
        )

        let relapse = RelapseBackupDTO(
            id: relapseID,
            trackerID: trackerID,
            previousStart: now.addingTimeInterval(-86400 * 60),
            restartedAt: now.addingTimeInterval(-86400 * 30),
            note: "Impreza firmowa",
            triggers: ["Stres", "Alkohol w otoczeniu"]
        )

        let checkIn = CheckInBackupDTO(
            id: checkInID,
            date: now.addingTimeInterval(-3600),
            mood: 4,
            craving: 2,
            triggers: ["Zmęczenie"],
            note: "Spokojny wieczór",
            trackerID: trackerID
        )

        let reason = ReasonBackupDTO(
            id: reasonID,
            text: "Dla rodziny i lepszego snu",
            trackerID: trackerID,
            createdAt: now.addingTimeInterval(-86400 * 30)
        )

        let contact = SupportContactBackupDTO(
            id: contactID,
            name: "Anna",
            phone: "+48123456789"
        )

        let originalFile = BackupFile(
            schemaVersion: 1,
            exportedAt: now,
            trackers: [tracker],
            relapses: [relapse],
            checkIns: [checkIn],
            reasons: [reason],
            supportContacts: [contact]
        )

        let exportedData = try originalFile.exportData()
        let importedFile = try BackupFile.importAndValidate(from: exportedData, now: now)

        XCTAssertEqual(importedFile.schemaVersion, originalFile.schemaVersion)
        XCTAssertEqual(importedFile.trackers.count, 1)
        XCTAssertEqual(importedFile.trackers.first?.id, trackerID)
        XCTAssertEqual(importedFile.trackers.first?.substanceKind, "alcohol")
        XCTAssertEqual(importedFile.trackers.first?.dailyUnits, 4.0)
        XCTAssertEqual(importedFile.trackers.first?.unitPrice, Decimal(string: "15.50"))
        XCTAssertEqual(importedFile.relapses.count, 1)
        XCTAssertEqual(importedFile.relapses.first?.triggers, ["Stres", "Alkohol w otoczeniu"])
        XCTAssertEqual(importedFile.checkIns.count, 1)
        XCTAssertEqual(importedFile.checkIns.first?.mood, 4)
        XCTAssertEqual(importedFile.reasons.count, 1)
        XCTAssertEqual(importedFile.reasons.first?.text, "Dla rodziny i lepszego snu")
        XCTAssertEqual(importedFile.supportContacts?.count, 1)
    }

    /// Test 10: Import validation rejects unknown schema version, duplicate IDs, future dates, corrupted JSON; error messages in Polish.
    func testBackupValidationErrorsInPolish() throws {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let id1 = UUID()

        // 1. Unknown schema version
        let invalidVersionFile = BackupFile(
            schemaVersion: 99,
            exportedAt: now
        )
        XCTAssertThrowsError(try invalidVersionFile.validate(now: now)) { error in
            guard let backupError = error as? BackupError,
                  case BackupError.unsupportedSchemaVersion(let v) = backupError else {
                XCTFail("Expected unsupportedSchemaVersion, got \(error)")
                return
            }
            XCTAssertEqual(v, 99)
            XCTAssertTrue(backupError.localizedDescription.contains("Nieobsługiwana wersja"))
        }

        // 2. Duplicate IDs
        let trackerA = TrackerBackupDTO(
            id: id1,
            substanceKind: "alcohol",
            startDate: now.addingTimeInterval(-1000),
            createdAt: now.addingTimeInterval(-1000),
            currencyCode: "PLN",
            unitLabel: "drinki",
            colorToken: "substanceTeal"
        )
        let trackerB = TrackerBackupDTO(
            id: id1, // duplicate!
            substanceKind: "cannabis",
            startDate: now.addingTimeInterval(-1000),
            createdAt: now.addingTimeInterval(-1000),
            currencyCode: "PLN",
            unitLabel: "gramy",
            colorToken: "substanceGreen"
        )
        let duplicateFile = BackupFile(
            schemaVersion: 1,
            exportedAt: now,
            trackers: [trackerA, trackerB]
        )
        XCTAssertThrowsError(try duplicateFile.validate(now: now)) { error in
            guard let backupError = error as? BackupError,
                  case BackupError.duplicateIDs(let entity, let dupId) = backupError else {
                XCTFail("Expected duplicateIDs, got \(error)")
                return
            }
            XCTAssertEqual(entity, "Tracker")
            XCTAssertEqual(dupId, id1)
            XCTAssertTrue(backupError.localizedDescription.contains("Zduplikowany identyfikator") ||
                          backupError.localizedDescription.contains("zduplikowany"))
        }

        // 3. Future dates
        let futureTracker = TrackerBackupDTO(
            id: UUID(),
            substanceKind: "alcohol",
            startDate: now.addingTimeInterval(86400 * 5), // in future!
            createdAt: now,
            currencyCode: "PLN",
            unitLabel: "drinki",
            colorToken: "substanceTeal"
        )
        let futureFile = BackupFile(
            schemaVersion: 1,
            exportedAt: now,
            trackers: [futureTracker]
        )
        XCTAssertThrowsError(try futureFile.validate(now: now)) { error in
            guard let backupError = error as? BackupError,
                  case BackupError.futureDate(let entity, _, _) = backupError else {
                XCTFail("Expected futureDate, got \(error)")
                return
            }
            XCTAssertEqual(entity, "Tracker.startDate")
            XCTAssertTrue(backupError.localizedDescription.contains("przyszłości"))
        }

        // 4. Corrupted JSON
        let corruptedData = Data("{\"schemaVersion\": 1, \"invalid_json...".utf8)
        XCTAssertThrowsError(try BackupFile.importAndValidate(from: corruptedData, now: now)) { error in
            guard let backupError = error as? BackupError,
                  case BackupError.corruptedJSON = backupError else {
                XCTFail("Expected corruptedJSON, got \(error)")
                return
            }
            XCTAssertTrue(backupError.localizedDescription.contains("uszkodzony"))
        }
    }
}
