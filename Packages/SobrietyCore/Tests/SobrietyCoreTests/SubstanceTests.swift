import XCTest
@testable import SobrietyCore

final class SubstanceTests: XCTestCase {
    /// Test 11: Every substance kind has a default unit, symbol, and localization key.
    func testEverySubstanceKindHasRequiredProperties() {
        XCTAssertGreaterThanOrEqual(SubstanceKind.allCases.count, 11)

        for kind in SubstanceKind.allCases {
            // Unit label must be present and non-empty
            XCTAssertFalse(kind.defaultUnitLabel.trimmingCharacters(in: .whitespaces).isEmpty, "Missing unit label for \(kind)")

            // Neutral SF Symbol must be present and non-empty
            XCTAssertFalse(kind.systemSymbolName.trimmingCharacters(in: .whitespaces).isEmpty, "Missing symbol for \(kind)")

            // Localization key must be properly formatted
            XCTAssertTrue(kind.localizedTitleKey.starts(with: "substance."), "Invalid localization key for \(kind)")

            // Color token must be defined
            XCTAssertTrue(kind.colorToken.starts(with: "substance"), "Invalid color token for \(kind)")
        }

        // Specific withdrawal warning checks for alcohol, benzodiazepines, opioids
        XCTAssertTrue(SubstanceKind.alcohol.requiresMedicalWarning)
        XCTAssertTrue(SubstanceKind.benzodiazepines.requiresMedicalWarning)
        XCTAssertTrue(SubstanceKind.opioids.requiresMedicalWarning)
        XCTAssertFalse(SubstanceKind.cannabis.requiresMedicalWarning)
        XCTAssertFalse(SubstanceKind.nicotineCigarettes.requiresMedicalWarning)
    }

    /// Test 13: Discreet mode displayName and displaySymbol never reveal the substance name or icon.
    func testDiscreetModeMasking() {
        // Case A: Tracker with alias defined
        let trackerWithAlias = SimpleTrackerDisplayItem(
            substanceKind: .alcohol,
            customName: "Mój alkoholowy licznik",
            alias: "Projekt Spokój"
        )

        // In normal mode: returns customName
        XCTAssertEqual(
            TrackerDisplayHelper.displayName(for: trackerWithAlias, discreet: false),
            "Mój alkoholowy licznik"
        )
        // In discreet mode: returns alias "Projekt Spokój", never reveals substance or custom name with substance
        let discreetName = TrackerDisplayHelper.displayName(for: trackerWithAlias, discreet: true)
        XCTAssertEqual(discreetName, "Projekt Spokój")
        XCTAssertFalse(discreetName.localizedCaseInsensitiveContains("alkohol"))

        // Case B: Tracker with NO alias
        let trackerWithoutAlias = SimpleTrackerDisplayItem(
            substanceKind: .alcohol,
            customName: nil,
            alias: nil
        )

        // In normal mode: returns localized substance key
        XCTAssertEqual(
            TrackerDisplayHelper.displayName(for: trackerWithoutAlias, discreet: false),
            "substance.alcohol"
        )
        // In discreet mode: returns neutral fallback "Licznik", NEVER substance name
        let neutralName = TrackerDisplayHelper.displayName(for: trackerWithoutAlias, discreet: true)
        XCTAssertEqual(neutralName, "Licznik")
        XCTAssertFalse(neutralName.localizedCaseInsensitiveContains("alcohol"))
        XCTAssertFalse(neutralName.localizedCaseInsensitiveContains("alkohol"))

        // Symbol masking
        let symbolNormal = TrackerDisplayHelper.displaySymbol(for: trackerWithAlias, discreet: false)
        let symbolDiscreet = TrackerDisplayHelper.displaySymbol(for: trackerWithAlias, discreet: true)
        XCTAssertEqual(symbolNormal, "drop")
        XCTAssertEqual(symbolDiscreet, TrackerDisplayHelper.discreetSymbolName)
    }
}
