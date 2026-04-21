import SwiftUI

struct LaunchScreen: View {
    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0
    @State private var wordmarkOpacity: Double = 0

    var body: some View {
        ZStack {
            ZStack {
                Color(red: 1.0, green: 0.972, blue: 0.974)
                RadialGradient(
                    colors: [
                        Color.pulseAccentSoft,
                        Color(red: 1.0, green: 0.958, blue: 0.962),
                        Color(red: 1.0, green: 0.972, blue: 0.974)
                    ],
                    center: .init(x: 0.5, y: 0.35),
                    startRadius: 0,
                    endRadius: 420
                )
            }
            .ignoresSafeArea()

            VStack(spacing: 20) {
                PulseHero(size: 120)
                    .scaleEffect(scale)
                    .opacity(opacity)

                Text("PULSE")
                    .font(.system(size: 17, weight: .heavy, design: .default))
                    .tracking(5)
                    .foregroundStyle(Color.pulseAccent)
                    .opacity(wordmarkOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.25)) {
                wordmarkOpacity = 1.0
            }
        }
    }
}
