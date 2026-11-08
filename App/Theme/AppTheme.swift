import SwiftUI

/// Design system tokens for colors, typography, and card styling.
/// High contrast, calm deep navy tones, warm accents, strictly without decorative gradients.
public enum AppTheme {
    public static let primaryNavy = Color(red: 15 / 255, green: 23 / 255, blue: 42 / 255)       // #0F172A
    public static let cardDark = Color(red: 30 / 255, green: 41 / 255, blue: 59 / 255)         // #1E293B
    public static let surfaceSubtle = Color(red: 51 / 255, green: 65 / 255, blue: 85 / 255)     // #334155
    public static let warmAccent = Color(red: 217 / 255, green: 119 / 255, blue: 6 / 255)      // #D97706 warm amber
    public static let supportiveGreen = Color(red: 22 / 255, green: 101 / 255, blue: 52 / 255)  // #166534

    /// Resolves semantic color for a substance token identifier.
    public static func color(for token: String) -> Color {
        switch token {
        case "substanceTeal":
            return Color(red: 13 / 255, green: 148 / 255, blue: 136 / 255)
        case "substanceSlate":
            return Color(red: 100 / 255, green: 116 / 255, blue: 139 / 255)
        case "substanceSky":
            return Color(red: 2 / 255, green: 132 / 255, blue: 199 / 255)
        case "substanceGreen":
            return Color(red: 34 / 255, green: 197 / 255, blue: 94 / 255)
        case "substanceOrange":
            return Color(red: 234 / 255, green: 88 / 255, blue: 12 / 255)
        case "substanceIndigo":
            return Color(red: 79 / 255, green: 70 / 255, blue: 229 / 255)
        case "substanceCrimson":
            return Color(red: 225 / 255, green: 29 / 255, blue: 72 / 255)
        case "substancePurple":
            return Color(red: 147 / 255, green: 51 / 255, blue: 234 / 255)
        case "substanceBrown":
            return Color(red: 180 / 255, green: 83 / 255, blue: 9 / 255)
        case "substanceGold":
            return Color(red: 202 / 255, green: 138 / 255, blue: 4 / 255)
        default:
            return Color(red: 37 / 255, green: 99 / 255, blue: 235 / 255)
        }
    }
}
