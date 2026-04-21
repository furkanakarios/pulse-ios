// NotificationsScreen.swift — Screen 4 of 5
// Ask for notification permission. Wire `onEnable` to UNUserNotificationCenter.

import SwiftUI

struct NotificationsScreen: View {
    var onEnable: () -> Void
    var onSkip: () -> Void
    var onBack: () -> Void

    @State private var appeared = false

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
        VStack(spacing: 0) {
            // Back button — left aligned
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

            // Centered header
            VStack(spacing: 16) {
                PulseChip(icon: "bell.fill", chipSize: 72)

                VStack(spacing: 10) {
                    Text("Stay on track,\neffortlessly.")
                        .font(PulseFont.titleMedium())
                        .tracking(-1)
                        .lineSpacing(2)
                        .foregroundStyle(Color.pulseText)
                        .multilineTextAlignment(.center)
                    Text("A quick ping when it's water time,\nhabit time, or a new day begins.")
                        .font(PulseFont.body(15))
                        .foregroundStyle(Color.pulseTextSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, PulseMetrics.horizontalPadding)
            .padding(.top, 4)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .animation(PulseAnimation.enterFade, value: appeared)

            Spacer(minLength: 20)

            // Notification cards
            VStack(spacing: 10) {
                ForEach(Array(notifications.enumerated()), id: \.offset) { idx, n in
                    notificationCard(n)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)
                        .animation(PulseAnimation.enterFade.delay(0.15 + Double(idx) * 0.09), value: appeared)
                }
            }
            .padding(.horizontal, PulseMetrics.horizontalPadding)

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

    private func notificationCard(_ n: MockNotification) -> some View {
        HStack(alignment: .top, spacing: 10) {
            // App icon
            ZStack {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(Color.pulseAccent)
                    .frame(width: 38, height: 38)
                Image(systemName: "heart.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline) {
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
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(Color.pulseSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.black.opacity(0.07), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}
