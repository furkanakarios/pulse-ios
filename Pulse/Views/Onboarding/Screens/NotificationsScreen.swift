// NotificationsScreen.swift — Screen 4 of 5
// Ask for notification permission. Wire `onEnable` to UNUserNotificationCenter.

import SwiftUI

struct NotificationsScreen: View {
    var onEnable: () -> Void
    var onSkip: () -> Void
    var onBack: () -> Void

    @State private var appeared = false
    @State private var bellShake = false

    private struct MockNotification {
        let title: String
        let body: String
        let time: String
    }

    private let notifications = [
        MockNotification(title: "Good morning ☀️", body: "Start with a glass of water and your 3 daily habits.", time: "9:00 AM"),
        MockNotification(title: "Time to hydrate", body: "You're 2 glasses behind your goal. A quick sip?", time: "1:30 PM"),
        MockNotification(title: "Don't break the streak 🔥", body: "1 habit left to check off — you've got this.", time: "9:00 PM"),
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
                    Text("Stay on track,\neffortlessly.")
                        .font(PulseFont.titleMedium())
                        .tracking(-1)
                        .lineSpacing(2)
                        .foregroundStyle(Color.pulseText)
                    Text("A quick ping when it's water time, habit time, or a new day begins.")
                        .font(PulseFont.body(15))
                        .foregroundStyle(Color.pulseTextSecondary)
                }

                VStack(spacing: 10) {
                    ForEach(Array(notifications.enumerated()), id: \.offset) { idx, n in
                        mockNotificationCard(n)
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 12)
                            .animation(PulseAnimation.enterFade.delay(0.15 + Double(idx) * 0.08), value: appeared)
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
                PulsePrimaryButton(title: "Enable reminders", action: onEnable)
                PulseSecondaryButton(title: "Not now", action: onSkip)
            }
            .padding(.horizontal, PulseMetrics.horizontalPadding)
            .padding(.bottom, PulseMetrics.footerBottomPadding - 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.pulseBackground)
        .onAppear { appeared = true }
    }

    private func mockNotificationCard(_ n: MockNotification) -> some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.pulseAccentSoft)
                    .frame(width: 36, height: 36)
                Image(systemName: "bolt.heart.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.pulseAccent)
            }
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("Pulse")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.pulseText)
                    Spacer()
                    Text(n.time)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.pulseTextSecondary)
                }
                Text(n.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.pulseText)
                Text(n.body)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.pulseTextSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .background(Color.pulseSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }
}
