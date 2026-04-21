// PulseHero.swift
import SwiftUI

struct PulseHero: View {
    var size: CGFloat = 240
    @State private var running = false

    var body: some View {
        ZStack {
            if running {
                animatedHero
            } else {
                staticHero
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                running = true
            }
        }
    }

    private var staticHero: some View {
        ZStack {
            RadialGradient(
                colors: [Color.pulseHeroGradientStart, Color.pulseHeroGradientMiddle, Color.pulseHeroGradientEnd],
                center: .center, startRadius: 0, endRadius: size * 0.9
            )
            .clipShape(Circle())

            Image(systemName: "heart.fill")
                .resizable().scaledToFit()
                .frame(width: size * 0.22, height: size * 0.22)
                .foregroundStyle(Color.pulseAccent)
                .shadow(color: Color.pulseAccent.opacity(0.35), radius: 12, x: 0, y: 4)
        }
    }

    private var animatedHero: some View {
        TimelineView(.animation) { ctx in
            let t = ctx.date.timeIntervalSinceReferenceDate
            ZStack {
                RadialGradient(
                    colors: [Color.pulseHeroGradientStart, Color.pulseHeroGradientMiddle, Color.pulseHeroGradientEnd],
                    center: .center, startRadius: 0, endRadius: size * 0.9
                )
                .clipShape(Circle())

                ForEach(0..<3, id: \.self) { i in
                    PulseRing(phase: ringPhase(t: t, offset: Double(i) * 0.66))
                        .stroke(Color.pulseAccent, lineWidth: 2)
                        .frame(width: size * 0.6, height: size * 0.6)
                }

                ECGLine()
                    .trim(from: 0, to: ecgTrim(t: t))
                    .stroke(Color.pulseAccent, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                    .frame(width: size * 0.55, height: size * 0.18)
                    .opacity(ecgOpacity(t: t))

                Image(systemName: "heart.fill")
                    .resizable().scaledToFit()
                    .frame(width: size * 0.22, height: size * 0.22)
                    .foregroundStyle(Color.pulseAccent)
                    .scaleEffect(heartScale(t: t))
                    .shadow(color: Color.pulseAccent.opacity(0.35), radius: 12, x: 0, y: 4)
            }
        }
    }

    private func ringPhase(t: TimeInterval, offset: Double) -> CGFloat {
        CGFloat(((t + offset).truncatingRemainder(dividingBy: 2.0)) / 2.0)
    }

    private func heartScale(t: TimeInterval) -> CGFloat {
        let beat = t.truncatingRemainder(dividingBy: 1.0)
        if beat < 0.08 { return 1.0 + CGFloat(beat / 0.08) * 0.08 }
        if beat < 0.16 { return 1.08 - CGFloat((beat - 0.08) / 0.08) * 0.05 }
        if beat < 0.24 { return 1.03 + CGFloat((beat - 0.16) / 0.08) * 0.06 }
        if beat < 0.34 { return 1.09 - CGFloat((beat - 0.24) / 0.10) * 0.09 }
        return 1.0
    }

    private func ecgTrim(t: TimeInterval) -> CGFloat {
        let p = t.truncatingRemainder(dividingBy: 2.4) / 2.4
        if p < 0.6 { return CGFloat(p / 0.6) }
        if p < 0.75 { return 1.0 }
        return CGFloat(1.0 - (p - 0.75) / 0.25)
    }

    private func ecgOpacity(t: TimeInterval) -> Double {
        let p = t.truncatingRemainder(dividingBy: 2.4) / 2.4
        return p < 0.85 ? 1.0 : max(0, 1.0 - (p - 0.85) / 0.15)
    }
}

private struct PulseRing: Shape {
    var phase: CGFloat
    var animatableData: CGFloat { get { phase } set { phase = newValue } }
    func path(in rect: CGRect) -> Path {
        let radius = rect.width * 1.1 * phase
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var p = Path()
        p.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
        return p
    }
}

private struct ECGLine: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height, midY = rect.midY
        p.move(to: CGPoint(x: 0, y: midY))
        p.addLine(to: CGPoint(x: w * 0.30, y: midY))
        p.addLine(to: CGPoint(x: w * 0.38, y: midY - h * 0.15))
        p.addLine(to: CGPoint(x: w * 0.45, y: midY + h * 0.55))
        p.addLine(to: CGPoint(x: w * 0.52, y: midY - h * 0.50))
        p.addLine(to: CGPoint(x: w * 0.60, y: midY))
        p.addLine(to: CGPoint(x: w, y: midY))
        return p
    }
}

#Preview {
    PulseHero().padding().background(Color.pulseBackground)
}
