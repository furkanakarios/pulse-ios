// FeaturesScreen.swift — Screen 2 of 5
import SwiftUI

struct FeaturesScreen: View {
    var onContinue: () -> Void
    var onBack: () -> Void

    @State private var appeared = false

    private let features: [(String, String, String)] = [
        ("drop.fill",         "Hydration",      "Set a daily goal and hit it with gentle nudges."),
        ("fork.knife",        "Nutrition Log",  "Quick, no-calorie-math meal entries. Just show up."),
        ("figure.run",        "Movement",       "Log workouts in seconds. Streaks keep you honest."),
        ("checkmark.circle.fill", "Daily Habits", "Build the small routines that compound every day.")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top bar with back
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.pulseText)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.top, 4)

            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Everything you need,")
                        .font(PulseFont.titleMedium())
                        .tracking(-1)
                        .foregroundStyle(Color.pulseText)
                    Text("nothing you don't.")
                        .font(PulseFont.titleMedium())
                        .tracking(-1)
                        .foregroundStyle(Color.pulseAccent)
                }
                Text("Four core trackers. All offline. No accounts, no clutter.")
                    .font(PulseFont.body(15))
                    .foregroundStyle(Color.pulseTextSecondary)
            }
            .padding(.horizontal, PulseMetrics.horizontalPadding)
            .padding(.top, 8)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .animation(PulseAnimation.enterFade, value: appeared)

            Spacer(minLength: 28)

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(features.enumerated()), id: \.offset) { idx, f in
                    FeatureRow(icon: f.0, title: f.1, subtitle: f.2)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(PulseAnimation.enterFade.delay(0.1 + Double(idx) * 0.08), value: appeared)
                    if idx < features.count - 1 {
                        Spacer(minLength: 0)
                    }
                }
            }
            .padding(.horizontal, PulseMetrics.horizontalPadding)
            .frame(maxHeight: .infinity)

            PulsePrimaryButton(title: "Continue", action: onContinue)
                .padding(.horizontal, PulseMetrics.horizontalPadding)
                .padding(.bottom, PulseMetrics.footerBottomPadding)
                .padding(.top, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pulseBackground)
        .onAppear { appeared = true }
    }
}
