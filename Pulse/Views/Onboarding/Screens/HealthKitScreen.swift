// HealthKitScreen.swift — Screen 3 of 5
// Connect Apple Health. On "Connect" tap, request HealthKit authorization
// (wire to your HealthKitManager — stubbed here with onConnect callback).

import SwiftUI

struct HealthKitScreen: View {
    var onConnect: () -> Void
    var onSkip: () -> Void
    var onBack: () -> Void

    @State private var appeared = false

    private let metrics = [
        "Heart rate",
        "Heart rate variability",
        "Resting heart rate",
        "Sleep analysis",
        "Workouts"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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

            VStack(alignment: .leading, spacing: 24) {
                // Heart icon chip
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.pulseAccentSoft)
                        .frame(width: 64, height: 64)
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(Color.pulseAccent)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Connect Apple Health")
                        .font(PulseFont.titleMedium())
                        .tracking(-1)
                        .lineSpacing(2)
                        .foregroundStyle(Color.pulseText)
                    Text("Pulse reads these metrics to build your daily summary. Nothing leaves your device.")
                        .font(PulseFont.body(15))
                        .foregroundStyle(Color.pulseTextSecondary)
                }

                VStack(spacing: 10) {
                    ForEach(metrics, id: \.self) { m in
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color.pulseAccent)
                                .frame(width: 20, height: 20)
                                .background(Color.pulseAccentSoft)
                                .clipShape(Circle())
                            Text(m)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color.pulseText)
                            Spacer()
                        }
                    }
                }
            }
            .padding(.horizontal, PulseMetrics.horizontalPadding)
            .padding(.top, 8)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .animation(PulseAnimation.enterFade, value: appeared)

            Spacer(minLength: 0)

            VStack(spacing: 4) {
                PulsePrimaryButton(title: "Connect Apple Health", action: onConnect)
                PulseSecondaryButton(title: "Not now", action: onSkip)
            }
            .padding(.horizontal, PulseMetrics.horizontalPadding)
            .padding(.bottom, PulseMetrics.footerBottomPadding - 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pulseBackground)
        .onAppear { appeared = true }
    }
}
