// FeaturesScreen.swift — Screen 2 of 5
import SwiftUI

struct FeaturesScreen: View {
    var onContinue: () -> Void
    var onBack: () -> Void

    @State private var appeared = false

    private let features: [(String, String, String)] = [
        ("waveform.path.ecg", "Heart rhythm insights", "Spot trends in your resting heart rate, HRV and recovery."),
        ("bed.double.fill",   "Sleep-aware",           "See how last night's sleep shapes today's readiness."),
        ("figure.run",        "Built for real life",   "A single morning check-in. No dashboards to decode."),
        ("lock.shield.fill",  "Private by default",    "Your data stays on your device. We never sell it.")
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
                Text("What you get")
                    .font(PulseFont.titleMedium())
                    .tracking(-1)
                    .foregroundStyle(Color.pulseText)
                Text("Four simple things, done well.")
                    .font(PulseFont.body(15))
                    .foregroundStyle(Color.pulseTextSecondary)
            }
            .padding(.horizontal, PulseMetrics.horizontalPadding)
            .padding(.top, 8)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .animation(PulseAnimation.enterFade, value: appeared)

            VStack(alignment: .leading, spacing: 20) {
                ForEach(Array(features.enumerated()), id: \.offset) { idx, f in
                    FeatureRow(icon: f.0, title: f.1, subtitle: f.2)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(PulseAnimation.enterFade.delay(0.1 + Double(idx) * 0.08), value: appeared)
                }
            }
            .padding(.horizontal, PulseMetrics.horizontalPadding)
            .padding(.top, 28)

            Spacer(minLength: 0)

            PulsePrimaryButton(title: "Continue", action: onContinue)
                .padding(.horizontal, PulseMetrics.horizontalPadding)
                .padding(.bottom, PulseMetrics.footerBottomPadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pulseBackground)
        .onAppear { appeared = true }
    }
}
