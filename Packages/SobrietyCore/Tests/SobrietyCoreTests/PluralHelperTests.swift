import XCTest
@testable import SobrietyCore

final class PluralHelperTests: XCTestCase {
    /// Test 12: Values 1, 2, 5, 12, 22, 25 for "dzień" yield grammatical forms one/few/many matching Polish plural rules.
    func testPolishPluralCategoriesAndFormatting() {
        // Categories check
        XCTAssertEqual(PluralHelper.category(for: 1), .one)
        XCTAssertEqual(PluralHelper.category(for: 2), .few)
        XCTAssertEqual(PluralHelper.category(for: 5), .many)
        XCTAssertEqual(PluralHelper.category(for: 12), .many)
        XCTAssertEqual(PluralHelper.category(for: 22), .few)
        XCTAssertEqual(PluralHelper.category(for: 25), .many)

        // Formats check for "dzień"
        XCTAssertEqual(PluralHelper.day.format(value: 1), "1 dzień")
        XCTAssertEqual(PluralHelper.day.format(value: 2), "2 dni")
        XCTAssertEqual(PluralHelper.day.format(value: 5), "5 dni")
        XCTAssertEqual(PluralHelper.day.format(value: 12), "12 dni")
        XCTAssertEqual(PluralHelper.day.format(value: 22), "22 dni")
        XCTAssertEqual(PluralHelper.day.format(value: 25), "25 dni")

        // Formats check for "godzina"
        XCTAssertEqual(PluralHelper.hour.format(value: 1), "1 godzina")
        XCTAssertEqual(PluralHelper.hour.format(value: 2), "2 godziny")
        XCTAssertEqual(PluralHelper.hour.format(value: 5), "5 godzin")
        XCTAssertEqual(PluralHelper.hour.format(value: 12), "12 godzin")
        XCTAssertEqual(PluralHelper.hour.format(value: 22), "22 godziny")
        XCTAssertEqual(PluralHelper.hour.format(value: 25), "25 godzin")

        // Formats check for "rok"
        XCTAssertEqual(PluralHelper.year.format(value: 1), "1 rok")
        XCTAssertEqual(PluralHelper.year.format(value: 2), "2 lata")
        XCTAssertEqual(PluralHelper.year.format(value: 5), "5 lat")
        XCTAssertEqual(PluralHelper.year.format(value: 12), "12 lat")
        XCTAssertEqual(PluralHelper.year.format(value: 22), "22 lata")
        XCTAssertEqual(PluralHelper.year.format(value: 25), "25 lat")
    }
}
