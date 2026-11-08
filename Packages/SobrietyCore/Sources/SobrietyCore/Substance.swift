import Foundation

/// Catalog of substance and addiction types supported by the tracker.
public enum SubstanceKind: String, Codable, CaseIterable, Identifiable, Sendable {
    case alcohol
    case nicotineCigarettes
    case eCigarettes
    case cannabis
    case amphetamine
    case cocaine
    case opioids
    case benzodiazepines
    case caffeine
    case gambling
    case other

    public var id: String { rawValue }

    /// Neutral SF Symbol representing this category without portraying paraphernalia.
    public var systemSymbolName: String {
        switch self {
        case .alcohol:
            return "drop"
        case .nicotineCigarettes:
            return "wind"
        case .eCigarettes:
            return "cloud"
        case .cannabis:
            return "leaf"
        case .amphetamine:
            return "bolt"
        case .cocaine:
            return "sparkle"
        case .opioids:
            return "shield"
        case .benzodiazepines:
            return "cross"
        case .caffeine:
            return "cup.and.saucer"
        case .gambling:
            return "circle.grid.2x2"
        case .other:
            return "star"
        }
    }

    /// Default unit of consumption for tracking and financial savings.
    public var defaultUnitLabel: String {
        switch self {
        case .alcohol:
            return "drinki"
        case .nicotineCigarettes:
            return "szt."
        case .eCigarettes:
            return "buchi"
        case .cannabis, .amphetamine, .cocaine:
            return "gramy"
        case .opioids:
            return "dawki"
        case .benzodiazepines:
            return "tabletki"
        case .caffeine:
            return "porcje"
        case .gambling:
            return "zakłady"
        case .other:
            return "jednostki"
        }
    }

    /// Semantic color token identifier used across UI themes.
    public var colorToken: String {
        switch self {
        case .alcohol:
            return "substanceTeal"
        case .nicotineCigarettes:
            return "substanceSlate"
        case .eCigarettes:
            return "substanceSky"
        case .cannabis:
            return "substanceGreen"
        case .amphetamine:
            return "substanceOrange"
        case .cocaine:
            return "substanceIndigo"
        case .opioids:
            return "substanceCrimson"
        case .benzodiazepines:
            return "substancePurple"
        case .caffeine:
            return "substanceBrown"
        case .gambling:
            return "substanceGold"
        case .other:
            return "substanceBlue"
        }
    }

    /// Localization key for the substance name.
    public var localizedTitleKey: String {
        return "substance.\(rawValue)"
    }

    /// Indicates whether abrupt cessation requires a safety advisory.
    /// Abrupt cessation of alcohol, benzodiazepines, and opioids can cause severe medical withdrawal.
    public var requiresMedicalWarning: Bool {
        switch self {
        case .alcohol, .benzodiazepines, .opioids:
            return true
        default:
            return false
        }
    }
}

/// Protocol providing essential tracker information for display and discreet mode filtering.
public protocol TrackerDisplayRepresentable: Sendable {
    var substanceKind: SubstanceKind { get }
    var customName: String? { get }
    var alias: String? { get }
}

/// Standalone concrete representation of `TrackerDisplayRepresentable`.
public struct SimpleTrackerDisplayItem: TrackerDisplayRepresentable, Equatable, Sendable {
    public let substanceKind: SubstanceKind
    public let customName: String?
    public let alias: String?

    public init(substanceKind: SubstanceKind, customName: String? = nil, alias: String? = nil) {
        self.substanceKind = substanceKind
        self.customName = customName
        self.alias = alias
    }
}

/// Helpers for displaying tracker information with discretion support.
public struct TrackerDisplayHelper: Sendable {
    public static let neutralFallbackName = "Licznik"
    public static let discreetSymbolName = "checkmark.seal"

    /// Returns the appropriate display name for a tracker, respecting discreet mode.
    /// In discreet mode, never returns the substance name. Returns the alias if present,
    /// or a neutral name ("Licznik") otherwise.
    public static func displayName(
        for tracker: some TrackerDisplayRepresentable,
        discreet: Bool
    ) -> String {
        if discreet {
            if let alias = tracker.alias?.trimmingCharacters(in: .whitespacesAndNewlines), !alias.isEmpty {
                return alias
            }
            return neutralFallbackName
        } else {
            if let custom = tracker.customName?.trimmingCharacters(in: .whitespacesAndNewlines), !custom.isEmpty {
                return custom
            }
            return tracker.substanceKind.localizedTitleKey
        }
    }

    /// Returns the display symbol for a tracker, respecting discreet mode.
    public static func displaySymbol(
        for tracker: some TrackerDisplayRepresentable,
        discreet: Bool
    ) -> String {
        if discreet {
            return discreetSymbolName
        }
        return tracker.substanceKind.systemSymbolName
    }
}
