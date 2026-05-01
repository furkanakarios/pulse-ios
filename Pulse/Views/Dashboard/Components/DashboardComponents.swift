//
//  DashboardComponents.swift
//  Pulse — V2 Stack redesign
//
//  All custom views used by the new DashboardView. Drop into
//  Views/Dashboard/Components/. No third-party deps. iOS 17+.
//

import SwiftUI

// MARK: - StackCard (the editorial row card)
struct DashboardStackCard<Visual: View>: View {
    let tag: String
    let color: Color
    let big: String
    let unit: String?
    let sub: String
    let cta: String
    let visual: Visual
    var onTap: (() -> Void)? = nil

    init(tag: String, color: Color, big: String, unit: String? = nil,
         sub: String, cta: String, onTap: (() -> Void)? = nil,
         @ViewBuilder visual: () -> Visual) {
        self.tag = tag; self.color = color
        self.big = big; self.unit = unit
        self.sub = sub; self.cta = cta
        self.onTap = onTap
        self.visual = visual()
    }

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        PulseEyebrow(text: tag, color: color)
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text(big)
                                .font(PulseType.bigNumber(44))
                                .tracking(-1.5)
                                .minimumScaleFactor(0.75)
                                .lineLimit(1)
                                .foregroundStyle(Color.pulseText)
                            if let unit {
                                Text(unit)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(Color.pulseTextMuted)
                            }
                        }
                        Text(sub)
                            .font(PulseType.bodyMuted)
                            .foregroundStyle(Color.pulseTextMuted)
                            .lineLimit(2)
                            .minimumScaleFactor(0.85)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer(minLength: 4)
                    visual.frame(maxWidth: 90, maxHeight: 70)
                }
                Divider().background(Color.pulseDivider).padding(.top, 14)
                HStack {
                    Text(cta).font(PulseType.cta).foregroundStyle(color)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(color)
                }
                .padding(.top, 12)
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.pulseSurface)
            )
            .pulseSoftShadow()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - WaveBar (water visual)
struct DashboardWaveBar: View {
    let pct: Double // 0...1
    let color: Color
    @State private var phase: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let fillH = h * CGFloat(min(max(pct, 0), 1))
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(color.opacity(0.12))
                WaveShape(amplitude: 3, frequency: 2, phase: phase, fillHeight: fillH)
                    .fill(color.opacity(0.85))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                WaveShape(amplitude: 2.5, frequency: 2, phase: phase + .pi, fillHeight: fillH - 4)
                    .fill(color)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                Text("\(Int(pct * 100))%")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(.white)
                    .tracking(-0.6)
            }
            .onAppear {
                withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                    phase = .pi * 2
                }
            }
        }
    }
}

private struct WaveShape: Shape {
    var amplitude: CGFloat
    var frequency: CGFloat
    var phase: CGFloat
    var fillHeight: CGFloat
    var animatableData: CGFloat {
        get { phase } set { phase = newValue }
    }
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let baseY = rect.height - fillHeight
        let step: CGFloat = 2
        p.move(to: CGPoint(x: 0, y: baseY))
        var x: CGFloat = 0
        while x <= rect.width {
            let y = baseY + sin((x / rect.width) * .pi * 2 * frequency + phase) * amplitude
            p.addLine(to: CGPoint(x: x, y: y))
            x += step
        }
        p.addLine(to: CGPoint(x: rect.width, y: rect.height))
        p.addLine(to: CGPoint(x: 0, y: rect.height))
        p.closeSubpath()
        return p
    }
}

// MARK: - MealDots
struct DashboardMealDots: View {
    let done: Int
    let total: Int
    let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<total, id: \.self) { i in
                HStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .strokeBorder(color.opacity(i < done ? 0 : 0.33), lineWidth: 1.5)
                            .background(Circle().fill(i < done ? color : .clear))
                            .frame(width: 14, height: 14)
                        if i < done {
                            Image(systemName: "checkmark")
                                .font(.system(size: 7, weight: .heavy))
                                .foregroundStyle(.white)
                        }
                    }
                    RoundedRectangle(cornerRadius: 2)
                        .fill(i < done ? color : color.opacity(0.15))
                        .frame(width: 56, height: 4)
                }
            }
        }
    }
}

// MARK: - HourlyBars
struct DashboardHourlyBars: View {
    let data: [Int]
    let color: Color
    var body: some View {
        let maxVal = max(data.max() ?? 1, 1)
        return HStack(alignment: .bottom, spacing: 3) {
            ForEach(Array(data.enumerated()), id: \.offset) { _, v in
                RoundedRectangle(cornerRadius: 2)
                    .fill(v > 0 ? color : color.opacity(0.15))
                    .frame(maxWidth: .infinity)
                    .frame(height: max(6, CGFloat(v) / CGFloat(maxVal) * 64))
            }
        }
        .frame(height: 64)
    }
}

// MARK: - MiniRings
struct DashboardMiniRings: View {
    let data: [Bool] // true = completed
    let color: Color
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 3), spacing: 6) {
            ForEach(Array(data.enumerated()), id: \.offset) { _, done in
                ZStack {
                    Circle().stroke(color.opacity(0.15), lineWidth: 3.5)
                    if done {
                        Circle()
                            .trim(from: 0, to: 1)
                            .stroke(color, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                    }
                }
                .frame(width: 26, height: 26)
            }
        }
    }
}

// MARK: - HistoryCard (Haftalık / Aylık)
struct DashboardHistoryCard<Visual: View>: View {
    let title: String
    let subtitle: String
    let color: Color
    let visual: Visual
    var onTap: (() -> Void)? = nil

    init(title: String, subtitle: String, color: Color,
         onTap: (() -> Void)? = nil,
         @ViewBuilder visual: () -> Visual) {
        self.title = title; self.subtitle = subtitle
        self.color = color; self.onTap = onTap
        self.visual = visual()
    }

    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 11, weight: .heavy))
                        .tracking(0.8)
                        .foregroundStyle(color)
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.pulseTextMuted)
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                }
                visual
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                HStack(spacing: 2) {
                    Text("Detay")
                        .font(PulseType.cta)
                        .foregroundStyle(color)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(color)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.pulseSurface)
            )
            .pulseSoftShadow()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - MiniBar (7 or 4 bars, 0…1 ratios)
struct DashboardMiniBar: View {
    let data: [Double]
    let color: Color
    var body: some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(Array(data.enumerated()), id: \.offset) { _, v in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(v > 0.02 ? color : color.opacity(0.14))
                    .frame(maxWidth: .infinity)
                    .frame(height: max(4, CGFloat(min(v, 1)) * 32))
            }
        }
    }
}

// MARK: - MiniMetric (Apple Health strip pill)
struct DashboardMiniMetric: View {
    let icon: String      // SF Symbol
    let value: String
    let sub: String
    let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: icon).font(.system(size: 14, weight: .semibold))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .tracking(-0.4)
                .minimumScaleFactor(0.75)
                .lineLimit(1)
                .foregroundStyle(Color.pulseText)
            Text(sub)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.pulseTextMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.pulseSurface)
        )
        .pulseSoftShadow()
    }
}
