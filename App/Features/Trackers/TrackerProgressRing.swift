import SwiftUI

/// Accessible circular progress ring displaying progress towards the next milestone.
public struct TrackerProgressRing: View {
    public let progress: Double
    public let tintColor: Color
    public let lineWidth: CGFloat

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(progress: Double, tintColor: Color = AppTheme.warmAccent, lineWidth: CGFloat = 8) {
        self.progress = max(0.0, min(1.0, progress))
        self.tintColor = tintColor
        self.lineWidth = lineWidth
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(tintColor.opacity(0.18), lineWidth: lineWidth)

            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(
                    tintColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: progress)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Postęp do następnego kamienia milowego")
        .accessibilityValue("\(Int(progress * 100))%")
    }
}
