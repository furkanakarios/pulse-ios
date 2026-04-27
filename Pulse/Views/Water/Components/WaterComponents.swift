//
//  WaterComponents.swift
//  Pulse — V2 Glass redesign
//
//  Custom views used by WaterView. iOS 17+, no third-party deps.
//

import SwiftUI

// MARK: - BottleProgress (the tall glass bottle on the left)
struct BottleProgress: View {
    let pct: Double            // 0...1
    var width: CGFloat = 86
    var height: CGFloat = 220

    @State private var phase: CGFloat = 0

    var body: some View {
        let clamped = min(max(pct, 0), 1)
        let fillH = (height - 30) * CGFloat(clamped)
        ZStack(alignment: .top) {
            // Glass body outline
            BottleShape()
                .fill(Color.pulseWater.opacity(0.06))
                .overlay(BottleShape().stroke(Color.pulseWater.opacity(0.25), lineWidth: 1))
                .frame(width: width, height: height)

            // Cap
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.pulseWater.opacity(0.5))
                .frame(width: 30, height: 6)
                .offset(x: 0, y: 0)

            // Water (clipped to bottle)
            ZStack {
                BottleWave(phase: phase, amplitude: 6, fillHeight: fillH)
                    .fill(LinearGradient(colors: [.pulseWaterLight, .pulseWaterDeep],
                                         startPoint: .top, endPoint: .bottom))
                BottleWave(phase: -phase * 1.4, amplitude: 8, fillHeight: max(fillH - 4, 0))
                    .fill(Color.pulseWater.opacity(0.4))
                // shine
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color.white.opacity(0.45))
                    .frame(width: 3, height: max(0, height - 70))
                    .offset(x: -((width / 2) - 14), y: 10)
            }
            .frame(width: width, height: height)
            .clipShape(BottleShape())

            // Percent overlay
            VStack {
                Spacer(minLength: 0)
                (Text("\(Int(clamped * 100))")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .tracking(-0.6)
                    .foregroundStyle(clamped > 0.18 ? Color.white : Color.pulseWaterDeep)
                + Text("%")
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundStyle(clamped > 0.18 ? Color.white : Color.pulseWaterDeep))
                    .shadow(color: clamped > 0.18 ? .black.opacity(0.18) : .clear,
                            radius: 4, x: 0, y: 1)
                Spacer().frame(height: max(20, fillH > 60 ? fillH - 30 : 24))
            }
            .frame(width: width, height: height)
            .allowsHitTesting(false)
        }
        .frame(width: width, height: height)
        .onAppear {
            withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
    }
}

private struct BottleShape: Shape {
    func path(in rect: CGRect) -> Path {
        // Mirrors the SVG path used in the HTML reference (86x220 baseline,
        // scaled to fit the rect).
        let s = CGSize(width: 86, height: 220)
        let sx = rect.width / s.width, sy = rect.height / s.height
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * sx, y: y * sy) }
        var path = Path()
        path.move(to: p(30, 4))
        path.addLine(to: p(56, 4))
        path.addLine(to: p(56, 18))
        path.addQuadCurve(to: p(60, 24), control: p(56, 22))
        path.addCurve(to: p(78, 54), control1: p(70, 30), control2: p(78, 40))
        path.addLine(to: p(78, 200))
        path.addQuadCurve(to: p(64, 214), control: p(78, 209))
        path.addLine(to: p(22, 214))
        path.addQuadCurve(to: p(8, 200), control: p(8, 209))
        path.addLine(to: p(8, 54))
        path.addCurve(to: p(26, 24), control1: p(8, 40), control2: p(16, 30))
        path.addQuadCurve(to: p(30, 18), control: p(30, 22))
        path.closeSubpath()
        return path
    }
}

private struct BottleWave: Shape {
    var phase: CGFloat
    var amplitude: CGFloat
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
            let y = baseY + sin((x / rect.width) * .pi * 4 + phase) * amplitude
            p.addLine(to: CGPoint(x: x, y: y))
            x += step
        }
        p.addLine(to: CGPoint(x: rect.width, y: rect.height))
        p.addLine(to: CGPoint(x: 0, y: rect.height))
        p.closeSubpath()
        return p
    }
}

// MARK: - HourlyTimeline (06–22 bars)
struct HourlyTimeline: View {
    /// hour (0–23) → ml total
    let entriesByHour: [Int: Int]
    var hours: ClosedRange<Int> = 6...22

    var body: some View {
        let max1 = max(entriesByHour.values.max() ?? 0, 350)
        VStack(spacing: 6) {
            HStack(alignment: .bottom, spacing: 3) {
                ForEach(Array(hours), id: \.self) { h in
                    let v = entriesByHour[h] ?? 0
                    let has = v > 0
                    RoundedRectangle(cornerRadius: 4)
                        .fill(has ? Color.pulseWater : Color.pulseWaterSoft)
                        .frame(maxWidth: .infinity)
                        .frame(height: has ? max(8, CGFloat(v) / CGFloat(max1) * 70) : 4)
                        .shadow(color: has ? Color.pulseWater.opacity(0.25) : .clear,
                                radius: 6, x: 0, y: 2)
                }
            }
            .frame(height: 70)

            HStack(spacing: 3) {
                ForEach(Array(Array(hours).enumerated()), id: \.offset) { idx, h in
                    Group {
                        if idx % 4 == 0 {
                            Text(String(format: "%02d", h))
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(Color.pulseTextMuted)
                        } else {
                            Text("")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

// MARK: - ContainerGlyph (4 cup/bottle SVG → SwiftUI Path)
enum ContainerKind { case glass, cup, mug, bottle }

struct ContainerGlyph: View {
    let kind: ContainerKind
    var body: some View {
        switch kind {
        case .glass:
            ZStack {
                GlassShape()
                    .fill(Color.pulseWaterSoft)
                    .overlay(GlassShape().stroke(Color.pulseWaterDeep, lineWidth: 1.2))
                GlassFilledShape().fill(Color.pulseWater)
            }
            .frame(width: 34, height: 40)
        case .cup:
            ZStack {
                CupShape()
                    .fill(Color.pulseWaterSoft)
                    .overlay(CupShape().stroke(Color.pulseWaterDeep, lineWidth: 1.2))
                CupFilledShape().fill(Color.pulseWater)
                CupHandle().stroke(Color.pulseWaterDeep, lineWidth: 1.2)
            }
            .frame(width: 38, height: 40)
        case .mug:
            ZStack {
                MugShape()
                    .fill(Color.pulseWaterSoft)
                    .overlay(MugShape().stroke(Color.pulseWaterDeep, lineWidth: 1.2))
                MugFilledShape().fill(Color.pulseWater)
                MugHandle().stroke(Color.pulseWaterDeep, lineWidth: 1.2)
            }
            .frame(width: 40, height: 40)
        case .bottle:
            ZStack {
                MiniBottleShape()
                    .fill(Color.pulseWaterSoft)
                    .overlay(MiniBottleShape().stroke(Color.pulseWaterDeep, lineWidth: 1.2))
                MiniBottleFilledShape().fill(Color.pulseWater)
            }
            .frame(width: 30, height: 42)
        }
    }
}

// Glyph shapes (paths translated 1-1 from the HTML SVGs)
private struct GlassShape: Shape {
    func path(in r: CGRect) -> Path {
        let sx = r.width / 34, sy = r.height / 40
        func p(_ x: CGFloat,_ y: CGFloat) -> CGPoint { .init(x: x*sx, y: y*sy) }
        var path = Path()
        path.move(to: p(6,4)); path.addLine(to: p(28,4)); path.addLine(to: p(25,36))
        path.addQuadCurve(to: p(23,38), control: p(25,38))
        path.addLine(to: p(11,38))
        path.addQuadCurve(to: p(9,36), control: p(9,38))
        path.closeSubpath()
        return path
    }
}
private struct GlassFilledShape: Shape {
    func path(in r: CGRect) -> Path {
        let sx = r.width / 34, sy = r.height / 40
        func p(_ x: CGFloat,_ y: CGFloat) -> CGPoint { .init(x: x*sx, y: y*sy) }
        var path = Path()
        path.move(to: p(8,18)); path.addLine(to: p(26,18)); path.addLine(to: p(24,36))
        path.addQuadCurve(to: p(22,38), control: p(24,38))
        path.addLine(to: p(12,38))
        path.addQuadCurve(to: p(10,36), control: p(10,38))
        path.closeSubpath()
        return path
    }
}
private struct CupShape: Shape {
    func path(in r: CGRect) -> Path {
        let sx = r.width / 38, sy = r.height / 40
        func p(_ x: CGFloat,_ y: CGFloat) -> CGPoint { .init(x: x*sx, y: y*sy) }
        var path = Path()
        path.move(to: p(5,8)); path.addLine(to: p(27,8)); path.addLine(to: p(27,32))
        path.addQuadCurve(to: p(23,36), control: p(27,36))
        path.addLine(to: p(9,36))
        path.addQuadCurve(to: p(5,32), control: p(5,36))
        path.closeSubpath()
        return path
    }
}
private struct CupFilledShape: Shape {
    func path(in r: CGRect) -> Path {
        let sx = r.width / 38, sy = r.height / 40
        func p(_ x: CGFloat,_ y: CGFloat) -> CGPoint { .init(x: x*sx, y: y*sy) }
        var path = Path()
        path.move(to: p(7,16)); path.addLine(to: p(25,16)); path.addLine(to: p(25,32))
        path.addQuadCurve(to: p(21,36), control: p(25,36))
        path.addLine(to: p(11,36))
        path.addQuadCurve(to: p(7,32), control: p(7,36))
        path.closeSubpath()
        return path
    }
}
private struct CupHandle: Shape {
    func path(in r: CGRect) -> Path {
        let sx = r.width / 38, sy = r.height / 40
        func p(_ x: CGFloat,_ y: CGFloat) -> CGPoint { .init(x: x*sx, y: y*sy) }
        var path = Path()
        path.move(to: p(27,14))
        path.addLine(to: p(32,14))
        path.addCurve(to: p(32,26), control1: p(36,14), control2: p(36,26))
        path.addLine(to: p(27,26))
        return path
    }
}
private struct MugShape: Shape {
    func path(in r: CGRect) -> Path {
        let sx = r.width / 40, sy = r.height / 40
        func p(_ x: CGFloat,_ y: CGFloat) -> CGPoint { .init(x: x*sx, y: y*sy) }
        var path = Path()
        path.move(to: p(4,6)); path.addLine(to: p(28,6)); path.addLine(to: p(28,34))
        path.addQuadCurve(to: p(25,37), control: p(28,37))
        path.addLine(to: p(7,37))
        path.addQuadCurve(to: p(4,34), control: p(4,37))
        path.closeSubpath()
        return path
    }
}
private struct MugFilledShape: Shape {
    func path(in r: CGRect) -> Path {
        let sx = r.width / 40, sy = r.height / 40
        func p(_ x: CGFloat,_ y: CGFloat) -> CGPoint { .init(x: x*sx, y: y*sy) }
        var path = Path()
        path.move(to: p(6,14)); path.addLine(to: p(26,14)); path.addLine(to: p(26,34))
        path.addQuadCurve(to: p(23,37), control: p(26,37))
        path.addLine(to: p(9,37))
        path.addQuadCurve(to: p(6,34), control: p(6,37))
        path.closeSubpath()
        return path
    }
}
private struct MugHandle: Shape {
    func path(in r: CGRect) -> Path {
        let sx = r.width / 40, sy = r.height / 40
        func p(_ x: CGFloat,_ y: CGFloat) -> CGPoint { .init(x: x*sx, y: y*sy) }
        var path = Path()
        path.move(to: p(28,12))
        path.addLine(to: p(33,12))
        path.addCurve(to: p(33,26), control1: p(37,12), control2: p(37,26))
        path.addLine(to: p(28,26))
        return path
    }
}
private struct MiniBottleShape: Shape {
    func path(in r: CGRect) -> Path {
        let sx = r.width / 30, sy = r.height / 42
        func p(_ x: CGFloat,_ y: CGFloat) -> CGPoint { .init(x: x*sx, y: y*sy) }
        var path = Path()
        path.move(to: p(11,2)); path.addLine(to: p(19,2)); path.addLine(to: p(19,8))
        path.addQuadCurve(to: p(20,10), control: p(19,9))
        path.addCurve(to: p(26,22), control1: p(24,12), control2: p(26,16))
        path.addLine(to: p(26,36))
        path.addQuadCurve(to: p(22,40), control: p(26,40))
        path.addLine(to: p(8,40))
        path.addQuadCurve(to: p(4,36), control: p(4,40))
        path.addLine(to: p(4,22))
        path.addCurve(to: p(10,10), control1: p(4,16), control2: p(6,12))
        path.addQuadCurve(to: p(11,8), control: p(11,9))
        path.closeSubpath()
        return path
    }
}
private struct MiniBottleFilledShape: Shape {
    func path(in r: CGRect) -> Path {
        let sx = r.width / 30, sy = r.height / 42
        func p(_ x: CGFloat,_ y: CGFloat) -> CGPoint { .init(x: x*sx, y: y*sy) }
        var path = Path()
        path.move(to: p(5,22)); path.addLine(to: p(25,22)); path.addLine(to: p(25,36))
        path.addQuadCurve(to: p(21,40), control: p(25,40))
        path.addLine(to: p(9,40))
        path.addQuadCurve(to: p(5,36), control: p(5,40))
        path.closeSubpath()
        return path
    }
}

// MARK: - WaterStatPill (small label/value chips inside hero card)
struct WaterStatPill: View {
    let label: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(0.4)
                .foregroundStyle(Color.pulseWaterDeep)
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.pulseText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10).padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.pulseWaterSoft)
        )
    }
}
