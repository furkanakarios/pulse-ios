// PulseChip.swift
// Animated coral rounded-square chip with expanding rings.
// Used on HealthKit and Notifications screens.
import SwiftUI

struct PulseChip: View {
    var icon: String
    var chipSize: CGFloat = 76

    @State private var beatScale: CGFloat = 1.0
    @State private var ring1Scale: CGFloat = 1.0
    @State private var ring1Opacity: Double = 0
    @State private var ring2Scale: CGFloat = 1.0
    @State private var ring2Opacity: Double = 0
    @State private var running = false

    private var cr: CGFloat { chipSize * 0.28 }
    private var outerFrame: CGFloat { chipSize * 2.4 }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cr)
                .stroke(Color.pulseAccent.opacity(ring2Opacity), lineWidth: 1.5)
                .frame(width: chipSize, height: chipSize)
                .scaleEffect(ring2Scale)

            RoundedRectangle(cornerRadius: cr)
                .stroke(Color.pulseAccent.opacity(ring1Opacity), lineWidth: 2)
                .frame(width: chipSize, height: chipSize)
                .scaleEffect(ring1Scale)

            RoundedRectangle(cornerRadius: cr, style: .continuous)
                .fill(Color.pulseAccent)
                .frame(width: chipSize, height: chipSize)
                .scaleEffect(beatScale)
                .shadow(color: Color.pulseAccent.opacity(0.3), radius: 12, x: 0, y: 4)

            Image(systemName: icon)
                .font(.system(size: chipSize * 0.38, weight: .semibold))
                .foregroundStyle(.white)
                .scaleEffect(beatScale)
        }
        .frame(width: outerFrame, height: outerFrame)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                running = true
                loopPulse()
            }
        }
        .onDisappear { running = false }
    }

    private func loopPulse() {
        guard running else { return }

        withAnimation(.spring(response: 0.11, dampingFraction: 0.42)) { beatScale = 1.12 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.65)) { beatScale = 1.0 }
        }

        ring1Scale = 1.0; ring1Opacity = 0.55
        withAnimation(.easeOut(duration: 1.1)) { ring1Scale = 1.85; ring1Opacity = 0 }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            guard running else { return }
            ring2Scale = 1.0; ring2Opacity = 0.32
            withAnimation(.easeOut(duration: 1.25)) { ring2Scale = 2.15; ring2Opacity = 0 }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) { loopPulse() }
    }
}

#Preview {
    VStack(spacing: 32) {
        PulseChip(icon: "heart.text.square.fill")
        PulseChip(icon: "bell.fill")
    }
    .padding()
    .background(Color.pulseBackground)
}
