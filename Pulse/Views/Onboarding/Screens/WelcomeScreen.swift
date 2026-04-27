// WelcomeScreen.swift — Screen 1 of 5
import SwiftUI

struct WelcomeScreen: View {
    var onContinue: () -> Void

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 40)

            PulseHero()
                .scaleEffect(appeared ? 1 : 0.9)
                .opacity(appeared ? 1 : 0)
                .animation(PulseAnimation.springy.delay(0.05), value: appeared)

            Spacer(minLength: 32)

            VStack(spacing: 12) {
                Text("PULSE")
                    .font(PulseFont.wordmark)
                    .tracking(4)
                    .foregroundStyle(Color.pulseAccent)
                Text("Your daily health,\nmade simple.")
                    .font(PulseFont.title(40))
                    .foregroundStyle(Color.pulseText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .tracking(-1)
                Text("Track water, meals, movement & habits —\nall private, all on your device.")
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
                PulsePrimaryButton(title: "Get Started", systemImage: "arrow.right", action: onContinue)
            }
            .padding(.horizontal, PulseMetrics.horizontalPadding)
            .padding(.bottom, PulseMetrics.footerBottomPadding)
            .opacity(appeared ? 1 : 0)
            .animation(PulseAnimation.enterFade.delay(0.3), value: appeared)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                Color(red: 1.0, green: 0.972, blue: 0.974)
                RadialGradient(
                    colors: [
                        Color.pulseAccentSoft,
                        Color(red: 1.0, green: 0.958, blue: 0.962),
                        Color(red: 1.0, green: 0.972, blue: 0.974)
                    ],
                    center: .init(x: 0.5, y: 0.0),
                    startRadius: 0,
                    endRadius: 460
                )
            }
            .ignoresSafeArea()
        )
        .onAppear { appeared = true }
    }
}
