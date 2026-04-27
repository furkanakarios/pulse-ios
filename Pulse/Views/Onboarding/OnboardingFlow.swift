// OnboardingFlow.swift
// Root coordinator. Drop this in your app and present on first launch.
//
// Usage (in PulseApp.swift):
//
//   @main
//   struct PulseApp: App {
//       @AppStorage("hasOnboarded") private var hasOnboarded = false
//       var body: some Scene {
//           WindowGroup {
//               if hasOnboarded {
//                   RootView()
//               } else {
//                   OnboardingFlow(onFinish: { hasOnboarded = true })
//               }
//           }
//       }
//   }

import SwiftUI

struct OnboardingFlow: View {
    var onFinish: () -> Void

    @State private var step: Int = 0
    private let total = 5

    var body: some View {
        ZStack(alignment: .top) {
            content
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .leading).combined(with: .opacity)
                ))

            // Progress indicator pinned to the top safe area
            PulseProgressDots(current: step, total: total)
                .padding(.top, 14)
                .padding(.horizontal, PulseMetrics.horizontalPadding)
        }
        .animation(PulseAnimation.springy, value: step)
    }

    @ViewBuilder
    private var content: some View {
        switch step {
        case 0: WelcomeScreen(onContinue: next)
        case 1: FeaturesScreen(onContinue: next, onBack: back)
        case 2: HealthKitScreen(onConnect: {
                    Task {
                        await HealthKitService.shared.requestAuthorization()
                        await MainActor.run { next() }
                    }
                }, onSkip: next, onBack: back)
        case 3: NotificationsScreen(onEnable: {
                    Task {
                        _ = await NotificationService.shared.requestAuthorization()
                        await MainActor.run { next() }
                    }
                }, onSkip: next, onBack: back)
        default: ReadyScreen(onFinish: onFinish)
        }
    }

    private func next() { step = min(step + 1, total - 1) }
    private func back() { step = max(step - 1, 0) }
}

#Preview {
    OnboardingFlow(onFinish: {})
}
