import SwiftUI

/// Accessible 4-4-4-4 Box Breathing exercise with reduceMotion support.
public struct BreathingExerciseView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var phaseIndex: Int = 0
    @State private var secondsInPhase: Int = 1
    @State private var isRunning: Bool = true
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private let phases = [
        ("Wdech", Color.blue),
        ("Zatrzymaj", AppTheme.warmAccent),
        ("Wydech", Color.teal),
        ("Zatrzymaj", AppTheme.surfaceSubtle)
    ]

    public init() {}

    public var body: some View {
        VStack(spacing: 12) {
            Text("Ćwiczenie oddechowe 4-4-4-4")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            ZStack {
                if !reduceMotion {
                    Circle()
                        .fill(phases[phaseIndex].1.opacity(0.15))
                        .scaleEffect(circleScale)
                        .animation(.easeInOut(duration: 1.0), value: circleScale)
                        .frame(width: 140, height: 140)
                }

                Circle()
                    .stroke(phases[phaseIndex].1, lineWidth: 3)
                    .frame(width: 120, height: 120)

                VStack(spacing: 4) {
                    Text(phases[phaseIndex].0)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text("\(secondsInPhase) / 4")
                        .font(.title3.monospacedDigit().bold())
                        .foregroundStyle(phases[phaseIndex].1)
                }
            }
            .frame(height: 150)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(phases[phaseIndex].0), sekunda \(secondsInPhase) z 4")
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onReceive(timer) { _ in
            guard isRunning else { return }
            tick()
        }
    }

    private var circleScale: CGFloat {
        switch phaseIndex {
        case 0: // Inhale
            return 0.8 + (CGFloat(secondsInPhase) * 0.08)
        case 1: // Hold
            return 1.12
        case 2: // Exhale
            return 1.12 - (CGFloat(secondsInPhase) * 0.08)
        default: // Hold
            return 0.8
        }
    }

    private func tick() {
        if secondsInPhase < 4 {
            secondsInPhase += 1
        } else {
            secondsInPhase = 1
            phaseIndex = (phaseIndex + 1) % phases.count
        }
    }
}
