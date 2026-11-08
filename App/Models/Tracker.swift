import Foundation
import SwiftData
import SobrietyCore

/// SwiftData persistent entity representing a tracked substance or habit.
@Model
public final class Tracker: TrackerDisplayRepresentable {
    public var id: UUID = UUID()
    public var substanceKindRaw: String = "other"
    public var customName: String?
    public var alias: String?
    public var startDate: Date = Date()
    public var createdAt: Date = Date()
    public var dailyUnits: Double?
    public var unitPrice: Decimal?
    public var currencyCode: String = "PLN"
    public var unitLabel: String = "jednostki"
    public var colorToken: String = "substanceBlue"
    public var isArchived: Bool = false

    @Relationship(deleteRule: .cascade, inverse: \Relapse.tracker)
    public var relapses: [Relapse] = []

    public var substanceKind: SubstanceKind {
        get {
            SubstanceKind(rawValue: substanceKindRaw) ?? .other
        }
        set {
            substanceKindRaw = newValue.rawValue
        }
    }

    public init(
        id: UUID = UUID(),
        substanceKind: SubstanceKind,
        customName: String? = nil,
        alias: String? = nil,
        startDate: Date,
        createdAt: Date = Date(),
        dailyUnits: Double? = nil,
        unitPrice: Decimal? = nil,
        currencyCode: String = "PLN",
        unitLabel: String? = nil,
        colorToken: String? = nil,
        isArchived: Bool = false
    ) {
        self.id = id
        self.substanceKindRaw = substanceKind.rawValue
        self.customName = customName
        self.alias = alias
        self.startDate = startDate
        self.createdAt = createdAt
        self.dailyUnits = dailyUnits
        self.unitPrice = unitPrice
        self.currencyCode = currencyCode
        self.unitLabel = unitLabel ?? substanceKind.defaultUnitLabel
        self.colorToken = colorToken ?? substanceKind.colorToken
        self.isArchived = isArchived
    }
}
