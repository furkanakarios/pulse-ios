// PulseHero.swift
import SwiftUI

struct PulseHero: View {
    var size: CGFloat = 155
    @State private var beatScale: CGFloat = 1.0
    @State private var ecgProgress: CGFloat = 0
    @State private var ecgOpacity: Double = 0
    @State private var running = false

    var body: some View {
        ZStack {
            Image(systemName: "heart.fill")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size * 0.9)
                .foregroundStyle(Color.pulseAccent)
                .scaleEffect(beatScale)
                .shadow(color: Color.pulseAccent.opacity(0.35), radius: 28, x: 0, y: 10)

            ECGLine()
                .trim(from: 0, to: ecgProgress)
                .stroke(Color.white.opacity(0.88), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                .frame(width: size * 0.52, height: size * 0.15)
                .opacity(ecgOpacity)
                .scaleEffect(beatScale)
        }
        .frame(width: size, height: size)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                running = true
                loopHeartbeat()
                loopECG()
            }
        }
        .onDisappear { running = false }
    }

    private func loopHeartbeat() {
        guard running else { return }
        withAnimation(.spring(response: 0.11, dampingFraction: 0.42)) { beatScale = 1.15 }
        after(0.15) {
            withAnimation(.spring(response: 0.12, dampingFraction: 0.52)) { beatScale = 0.98 }
            after(0.13) {
                withAnimation(.spring(response: 0.10, dampingFraction: 0.42)) { beatScale = 1.08 }
                after(0.13) {
                    withAnimation(.spring(response: 0.18, dampingFraction: 0.62)) { beatScale = 1.0 }
                    after(0.9) { loopHeartbeat() }
                }
            }
        }
    }

    private func loopECG() {
        guard running else { return }
        ecgProgress = 0
        withAnimation(.easeIn(duration: 0.15)) { ecgOpacity = 1 }
        withAnimation(.linear(duration: 1.0)) { ecgProgress = 1 }
        after(1.5) {
            withAnimation(.easeIn(duration: 0.3)) { ecgOpacity = 0 }
            after(0.4) { loopECG() }
        }
    }

    private func after(_ seconds: Double, _ action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: action)
    }
}

private struct ECGLine: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height, midY = rect.midY
        p.move(to: CGPoint(x: 0, y: midY))
        p.addLine(to: CGPoint(x: w * 0.28, y: midY))
        p.addLine(to: CGPoint(x: w * 0.36, y: midY - h * 0.12))
        p.addLine(to: CGPoint(x: w * 0.44, y: midY + h * 0.55))
        p.addLine(to: CGPoint(x: w * 0.52, y: midY - h * 0.50))
        p.addLine(to: CGPoint(x: w * 0.60, y: midY))
        p.addLine(to: CGPoint(x: w, y: midY))
        return p
    }
}

#Preview {
    ZStack {
        Color(red: 1, green: 0.94, blue: 0.95)
        PulseHero()
    }
}
