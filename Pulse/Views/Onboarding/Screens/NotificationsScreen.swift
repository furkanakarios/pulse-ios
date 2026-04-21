// NotificationsScreen.swift — Screen 4 of 5
// Ask for notification permission. Wire `onEnable` to UNUserNotificationCenter.

import SwiftUI

struct NotificationsScreen: View {
    var onEnable: () -> Void
    var onSkip: () -> Void
    var onBack: () -> Void

    @State private var appeared = false
    @State private var bellShake = false
    @State private var morning = true
    @State private var trends = true
    @State private var weekly = false

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
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.pulseAccentSoft)
                        .frame(width: 64, height: 64)
                    Image(systemName: "bell.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Color.pulseAccent)
                        .rotationEffect(.degrees(bellShake ? -10 : 10))
                        .animation(.easeInOut(duration: 0.12).repeatCount(6, autoreverses: true), value: bellShake)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { bellShake = true }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Stay in the loop\n— gently.")
                        .font(PulseFont.titleMedium())
                        .tracking(-1)
                        .lineSpacing(2)
                        .foregroundStyle(Color.pulseText)
                    Text("Choose what's worth a tap. Everything else stays quiet.")
                        .font(PulseFont.body(15))
                        .foregroundStyle(Color.pulseTextSecondary)
                }

                VStack(spacing: 10) {
                    PermissionRow(icon: "sunrise.fill", title: "Morning summary",
                                  subtitle: "One notification, 8 AM.",
                                  granted: $morning)
                    PermissionRow(icon: "chart.line.uptrend.xyaxis", title: "Trend alerts",
                                  subtitle: "When something meaningful changes.",
                                  granted: $trends)
                    PermissionRow(icon: "calendar", title: "Weekly recap",
                                  subtitle: "Sunday evenings.",
                                  granted: $weekly)
                }
            }
            .padding(.horizontal, PulseMetrics.horizontalPadding)
            .padding(.top, 8)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .animation(PulseAnimation.enterFade, value: appeared)

            Spacer(minLength: 0)

            VStack(spacing: 4) {
                PulsePrimaryButton(title: "Enable notifications", action: onEnable)
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
