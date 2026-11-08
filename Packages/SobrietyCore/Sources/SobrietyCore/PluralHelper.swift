import Foundation

/// Grammatical plural categories defined for Polish numeral inflections.
public enum PolishPluralCategory: String, Equatable, Sendable {
    case one
    case few
    case many
    case other

    /// Determines the grammatical plural category for an integer according to Polish rules.
    /// - `one`: 1
    /// - `few`: numbers ending in 2-4, except those ending in 12-14
    /// - `many`: numbers ending in 0, 1 (except 1), 5-9, or 12-14
    public static func category(for value: Int) -> PolishPluralCategory {
        let absVal = abs(value)
        if absVal == 1 {
            return .one
        }

        let mod10 = absVal % 10
        let mod100 = absVal % 100

        if (mod10 >= 2 && mod10 <= 4) && !(mod100 >= 12 && mod100 <= 14) {
            return .few
        }

        return .many
    }
}

/// Helper struct storing inflections for one, few, and many forms in Polish.
public struct PolishPluralRule: Sendable {
    public let one: String
    public let few: String
    public let many: String

    public init(one: String, few: String, many: String) {
        self.one = one
        self.few = few
        self.many = many
    }

    /// Returns the appropriate inflection for the given value.
    public func word(for value: Int) -> String {
        switch PolishPluralCategory.category(for: value) {
        case .one:
            return one
        case .few:
            return few
        case .many, .other:
            return many
        }
    }

    /// Formats the integer along with its inflected unit word.
    public func format(value: Int, includeNumber: Bool = true) -> String {
        let w = word(for: value)
        return includeNumber ? "\(value) \(w)" : w
    }
}

/// Standard plural dictionary for time and counter units in Polish.
public struct PluralHelper: Sendable {
    public static let day = PolishPluralRule(one: "dzień", few: "dni", many: "dni")
    public static let hour = PolishPluralRule(one: "godzina", few: "godziny", many: "godzin")
    public static let minute = PolishPluralRule(one: "minuta", few: "minuty", many: "minut")
    public static let second = PolishPluralRule(one: "sekunda", few: "sekundy", many: "sekund")
    public static let month = PolishPluralRule(one: "miesiąc", few: "miesiące", many: "miesięcy")
    public static let year = PolishPluralRule(one: "rok", few: "lata", many: "lat")
    public static let piece = PolishPluralRule(one: "sztuka", few: "sztuki", many: "sztuk")

    /// Helper to resolve category for a value.
    public static func category(for value: Int) -> PolishPluralCategory {
        return PolishPluralCategory.category(for: value)
    }
}
