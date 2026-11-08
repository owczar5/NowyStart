import XCTest
@testable import SobrietyCore

final class ResourcesTests: XCTestCase {
    /// Test 14: Resources.json parses successfully, every entry has phone number and verified flag.
    func testResourcesJSONParsingAndContent() throws {
        // Attempt loading via Bundle.module (SPM resource) or direct file paths
        var jsonData: Data? = nil

        #if SWIFT_PACKAGE
        if let moduleURL = Bundle.module.url(forResource: "Resources", withExtension: "json") {
            jsonData = try? Data(contentsOf: moduleURL)
        }
        #endif

        if jsonData == nil {
            let candidatePaths = [
                "Tests/SobrietyCoreTests/Resources/Resources.json",
                "Packages/SobrietyCore/Tests/SobrietyCoreTests/Resources/Resources.json",
                "App/Resources/Resources.json",
                "Resources.json"
            ]
            for path in candidatePaths {
                let url = URL(fileURLWithPath: path)
                if let data = try? Data(contentsOf: url) {
                    jsonData = data
                    break
                }
            }
        }

        guard let data = jsonData else {
            XCTFail("Failed to locate or read Resources.json")
            return
        }

        let catalog = try ResourcesCatalog.load(from: data)
        XCTAssertEqual(catalog.version, 1)
        XCTAssertFalse(catalog.disclaimer.isEmpty)
        XCTAssertEqual(catalog.disclaimer, "Ta aplikacja nie zastępuje pomocy medycznej ani terapii.")

        let poland = catalog.countries.first { $0.countryCode == "PL" }
        XCTAssertNotNil(poland, "Missing PL country resources in catalog")

        guard let plResources = poland?.resources else {
            XCTFail("PL resources are nil")
            return
        }

        // Must have exactly the 3 sanctioned entries: 112, 116 123, 800 199 990
        XCTAssertEqual(plResources.count, 3)

        let phoneNumbers = Set(plResources.map { $0.phoneNumber })
        XCTAssertTrue(phoneNumbers.contains("112"))
        XCTAssertTrue(phoneNumbers.contains("116 123"))
        XCTAssertTrue(phoneNumbers.contains("800 199 990"))

        for resource in plResources {
            // Every entry must have non-empty name and description
            XCTAssertFalse(resource.name.isEmpty)
            XCTAssertFalse(resource.description.isEmpty)

            // Must have a valid phone number and tel: URL
            XCTAssertFalse(resource.phoneNumber.isEmpty)
            XCTAssertNotNil(resource.phoneURL)
            XCTAssertEqual(resource.phoneURL?.scheme, "tel")

            // Verified flag must be false as explicitly mandated
            XCTAssertFalse(resource.verified, "Entry \(resource.name) should have verified: false")
        }
    }
}
