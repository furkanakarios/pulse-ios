// PulseProgress.swift
// Segmented onboarding progress indicator.
// Style matches the "dots" variant from the web prototype (animated pill for
// the active step). For bar/stepped, swap the implementation.

import SwiftUI

struct PulseProgressDots: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { i in
                Capsule()
                    .fill(i == current ? Color.pulseAccent : Color.black.opacity(0.12))
                    .frame(width: i == current ? 22 : 6, height: 6)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: current)
            }
        }
    }
}

struct PulseProgressBar: View {
    let current: Int
    let total: Int
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.black.opacity(0.12))
                Capsule()
                    .fill(Color.pulseAccent)
                    .frame(width: geo.size.width * CGFloat(current + 1) / CGFloat(total))
                    .animation(.spring(response: 0.45, dampingFraction: 0.8), value: current)
            }
        }
        .frame(height: 4)
    }
}
