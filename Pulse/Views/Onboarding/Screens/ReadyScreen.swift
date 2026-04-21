// ReadyScreen.swift — Screen 5 of 5
// Final confetti-ish burst + "Open Pulse" CTA.

import SwiftUI

struct ReadyScreen: View {
    var onFinish: () -> Void

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.pulseAccentSoft)
                    .frame(width: 160, height: 160)
                    .scaleEffect(appeared ? 1 : 0.6)
                    .opacity(appeared ? 1 : 0)
                    .animation(PulseAnimation.springy, value: appeared)

                Image(systemName: "checkmark")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(Color.pulseAccent)
                    .scaleEffect(appeared ? 1 : 0.2)
                    .animation(PulseAnimation.springy.delay(0.1), value: appeared)

                // Simple confetti-ish accents
                ForEach(0..<8, id: \.self) { i in
                    Circle()
                        .fill(Color.pulseAccent)
                        .frame(width: 8, height: 8)
                        .offset(x: cos(Double(i) * .pi / 4) * 110,
                                y: sin(Double(i) * .pi / 4) * 110)
                        .opacity(appeared ? 0.8 : 0)
                        .scaleEffect(appeared ? 1 : 0.3)
                        .animation(PulseAnimation.springy.delay(0.2 + Double(i) * 0.03), value: appeared)
                }
            }

            Spacer(minLength: 32)

            VStack(spacing: 12) {
                Text("You're all set!")
                    .font(PulseFont.title(36))
                    .tracking(-1)
                    .foregroundStyle(Color.pulseText)
                Text("Your first day starts now. Log a glass of water and we're off.")
                    .font(PulseFont.body(15))
                    .foregroundStyle(Color.pulseTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, PulseMetrics.horizontalPadding)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .animation(PulseAnimation.enterFade.delay(0.3), value: appeared)

            Spacer()

            PulsePrimaryButton(title: "Let's go", systemImage: "arrow.right", action: onFinish)
                .padding(.horizontal, PulseMetrics.horizontalPadding)
                .padding(.bottom, PulseMetrics.footerBottomPadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pulseBackground)
        .onAppear { appeared = true }
    }
}
