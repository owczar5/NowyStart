import Foundation

/// Individual helpline or emergency support resource.
public struct SupportResourceItem: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let description: String
    public let phoneNumber: String
    public let verified: Bool

    public init(
        id: String,
        name: String,
        description: String,
        phoneNumber: String,
        verified: Bool
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.phoneNumber = phoneNumber
        self.verified = verified
    }

    /// URL representation for placing a phone call (`tel:` scheme).
    public var phoneURL: URL? {
        let sanitized = phoneNumber.replacingOccurrences(of: " ", with: "")
        return URL(string: "tel:\(sanitized)")
    }
}

/// Collection of resources organized by country.
public struct CountryResources: Codable, Equatable, Sendable {
    public let countryCode: String
    public let countryName: String
    public let resources: [SupportResourceItem]

    public init(countryCode: String, countryName: String, resources: [SupportResourceItem]) {
        self.countryCode = countryCode
        self.countryName = countryName
        self.resources = resources
    }
}

/// Catalog holding all emergency contacts and crisis support hotlines.
public struct ResourcesCatalog: Codable, Equatable, Sendable {
    public let version: Int
    public let countries: [CountryResources]
    public let disclaimer: String

    public init(version: Int, countries: [CountryResources], disclaimer: String) {
        self.version = version
        self.countries = countries
        self.disclaimer = disclaimer
    }

    /// Loads and parses the catalog from JSON data.
    public static func load(from data: Data) throws -> ResourcesCatalog {
        let decoder = JSONDecoder()
        return try decoder.decode(ResourcesCatalog.self, from: data)
    }
}
