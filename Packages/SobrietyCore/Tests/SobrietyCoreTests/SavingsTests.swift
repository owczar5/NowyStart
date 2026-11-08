import XCTest
@testable import SobrietyCore

final class SavingsTests: XCTestCase {
    /// Test 6: Fractional days calculation, missing data yields nil, unit price 0 yields 0 (not an error).
    func testSavingsCalculations() {
        // Fractional days: 2.5 days (216,000 seconds) at 20 units/day = 50 units avoided
        let seconds2_5Days: TimeInterval = 2.5 * 86_400.0
        let avoided = Savings.unitsAvoided(dailyUnits: 20.0, elapsedSeconds: seconds2_5Days)
        XCTAssertEqual(avoided, 50.0)

        // Money saved with price 2.50 per unit: 50 * 2.50 = 125.00
        let saved = Savings.moneySaved(dailyUnits: 20.0, unitPrice: Decimal(string: "2.50"), elapsedSeconds: seconds2_5Days)
        XCTAssertEqual(saved, Decimal(string: "125.00"))

        // Price 0 -> returns 0 (not error, not nil)
        let savedZeroPrice = Savings.moneySaved(dailyUnits: 20.0, unitPrice: Decimal.zero, elapsedSeconds: seconds2_5Days)
        XCTAssertEqual(savedZeroPrice, Decimal.zero)

        // Missing daily units -> nil result
        let missingUnits = Savings.moneySaved(dailyUnits: nil, unitPrice: Decimal(10), elapsedSeconds: seconds2_5Days)
        XCTAssertNil(missingUnits)
        XCTAssertNil(Savings.unitsAvoided(dailyUnits: nil, elapsedSeconds: seconds2_5Days))

        // Missing unit price -> nil result
        let missingPrice = Savings.moneySaved(dailyUnits: 20.0, unitPrice: nil, elapsedSeconds: seconds2_5Days)
        XCTAssertNil(missingPrice)

        // Negative elapsed seconds or units -> nil
        XCTAssertNil(Savings.unitsAvoided(dailyUnits: -5.0, elapsedSeconds: seconds2_5Days))
        XCTAssertNil(Savings.moneySaved(dailyUnits: 20.0, unitPrice: Decimal(-5), elapsedSeconds: seconds2_5Days))
        XCTAssertNil(Savings.unitsAvoided(dailyUnits: 20.0, elapsedSeconds: -100))
    }
}
