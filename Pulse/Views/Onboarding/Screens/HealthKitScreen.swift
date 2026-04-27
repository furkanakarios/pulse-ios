// HealthKitScreen.swift — Screen 3 of 5
// Connect Apple Health. On "Connect" tap, request HealthKit authorization
// (wire to your HealthKitManager — stubbed here with onConnect callback).

import SwiftUI

struct HealthKitScreen: View {
    var onConnect: () -> Void
    var onSkip: () -> Void
    var onBack: () -> Void

    @State private var appeared = false

    private let metrics: [(String, String)] = [
        ("figure.walk", "Steps & distance"),
        ("flame.fill",  "Active calories"),
        ("figure.run",  "Workouts")
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

            VStack(alignment: .leading, spacing: 20) {
                PulseChip(icon: "heart.fill", chipSize: 72)
                    .frame(maxWidth: .infinity, alignment: .center)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Sync with Apple Health")
                        .font(PulseFont.titleMedium())
                        .tracking(-1)
                        .lineSpacing(2)
                        .foregroundStyle(Color.pulseText)
                    Text("Pull your steps, calories & workouts automatically. You stay in control of what syncs.")
                        .font(PulseFont.body(15))
                        .foregroundStyle(Color.pulseTextSecondary)
                }

                VStack(alignment: .leading, spacing: 20) {
                    ForEach(metrics, id: \.1) { icon, label in
                        HStack(alignment: .top, spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.pulseAccentSoft)
                                    .frame(width: 48, height: 48)
                                Image(systemName: icon)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(Color.pulseAccent)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(label)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(Color.pulseText)
                            }
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.pulseAccent)
                                .font(.system(size: 22))
                        }
                    }
                }

                HStack(spacing: 6) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.pulseTextSecondary)
                    Text("Nothing leaves your device. Ever.")
                        .font(PulseFont.caption(13))
                        .foregroundStyle(Color.pulseTextSecondary)
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
                PulseSecondaryButton(title: "Maybe later", action: onSkip)
            }
            .padding(.horizontal, PulseMetrics.horizontalPadding)
            .padding(.bottom, PulseMetrics.footerBottomPadding - 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pulseBackground)
        .onAppear { appeared = true }
    }
}
