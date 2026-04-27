// PulsePrimaryButton.swift
// Coral CTA used throughout onboarding. Pressed-state scale + brightness.

import SwiftUI

struct PulsePrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    var action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                if let icon = systemImage {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: PulseMetrics.buttonHeight)
            .background(Color.pulseAccent)
            .clipShape(RoundedRectangle(cornerRadius: PulseMetrics.buttonRadius, style: .continuous))
            .shadow(color: Color.pulseAccent.opacity(0.25), radius: 12, x: 0, y: 6)
            .scaleEffect(pressed ? 0.97 : 1)
            .brightness(pressed ? -0.05 : 0)
            .animation(.easeOut(duration: 0.15), value: pressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded   { _ in pressed = false }
        )
    }
}

struct PulseSecondaryButton: View {
    let title: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.pulseTextSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }
}
