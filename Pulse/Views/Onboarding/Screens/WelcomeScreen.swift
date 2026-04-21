// WelcomeScreen.swift — Screen 1 of 5
import SwiftUI

struct WelcomeScreen: View {
    var onContinue: () -> Void

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 40)

            PulseHero(size: 240)
                .scaleEffect(appeared ? 1 : 0.9)
                .opacity(appeared ? 1 : 0)
                .animation(PulseAnimation.springy.delay(0.05), value: appeared)

            Spacer(minLength: 32)

            VStack(spacing: 12) {
                Text("PULSE")
                    .font(PulseFont.wordmark)
                    .tracking(4)
                    .foregroundStyle(Color.pulseAccent)
                Text("Your heart,\ndecoded daily.")
                    .font(PulseFont.title(40))
                    .foregroundStyle(Color.pulseText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .tracking(-1)
                Text("Simple insights from your Apple Watch.\nNo dashboards. No noise.")
                    .font(PulseFont.body(15))
                    .foregroundStyle(Color.pulseTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
            .padding(.horizontal, PulseMetrics.horizontalPadding)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 16)
            .animation(PulseAnimation.enterFade.delay(0.15), value: appeared)

            Spacer()

            VStack(spacing: 8) {
                PulsePrimaryButton(title: "Get started", action: onContinue)
                Text("Takes less than a minute")
                    .font(PulseFont.caption(12))
                    .foregroundStyle(Color.pulseTextSecondary)
                    .padding(.top, 4)
            }
            .padding(.horizontal, PulseMetrics.horizontalPadding)
            .padding(.bottom, PulseMetrics.footerBottomPadding)
            .opacity(appeared ? 1 : 0)
            .animation(PulseAnimation.enterFade.delay(0.3), value: appeared)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pulseBackground)
        .onAppear { appeared = true }
    }
}
