//
//  PulseTheme+Redesign.swift
//  Pulse
//
//  Drop-in token additions for the V2 redesign (Stack Dashboard + Glass Water).
//  pulseSurface and pulseText already defined in PulseTheme.swift — omitted here.
//

import SwiftUI

// MARK: - Color tokens for the redesign
extension Color {
    // Background tones
    static let pulseBgPage     = Color(red: 0.949, green: 0.949, blue: 0.953) // #F2F2F4
    static let pulseDivider    = Color(red: 0, green: 0, blue: 0, opacity: 0.06)

    // Text muted (new token, no conflict)
    static let pulseTextMuted  = Color(red: 0.420, green: 0.420, blue: 0.460) // #6B6B75

    // Accent (coral) — keep aligned with your existing pulseAccent
    static let pulseCoral      = Color(red: 1.0,   green: 0.302, blue: 0.369) // #FF4D5E
    static let pulseCoralSoft  = Color(red: 1.0,   green: 0.894, blue: 0.906) // #FFE4E7

    // Water (teal)
    static let pulseWater      = Color(red: 0.059, green: 0.694, blue: 0.722) // #0FB1B8
    static let pulseWaterDeep  = Color(red: 0.039, green: 0.541, blue: 0.565) // #0A8A90
    static let pulseWaterLight = Color(red: 0.149, green: 0.776, blue: 0.804) // #26C6CD
    static let pulseWaterSoft  = Color(red: 0.878, green: 0.965, blue: 0.969) // #E0F6F7

    // Per-domain accents used by Stack dashboard
    static let pulseNutrition     = Color(red: 1.0,   green: 0.557, blue: 0.157) // #FF8E28
    static let pulseNutritionSoft = Color(red: 1.0,   green: 0.929, blue: 0.871) // #FFEDDF
    static let pulseExercise      = Color(red: 0.482, green: 0.424, blue: 1.0)   // #7B6CFF
    static let pulseExerciseSoft  = Color(red: 0.929, green: 0.918, blue: 1.0)   // #EDEAFF
    static let pulseHabit         = Color(red: 0.039, green: 0.706, blue: 0.553) // #0AB48D
    static let pulseHabitSoft     = Color(red: 0.886, green: 0.969, blue: 0.945) // #E2F7F1
}

// MARK: - Shadows
struct PulseShadow {
    static let soft = (color: Color.black.opacity(0.06), radius: 14.0, x: 0.0, y: 6.0)
    static let card = (color: Color.black.opacity(0.08), radius: 24.0, x: 0.0, y: 12.0)
}

extension View {
    func pulseSoftShadow() -> some View {
        shadow(color: PulseShadow.soft.color,
               radius: PulseShadow.soft.radius,
               x: PulseShadow.soft.x, y: PulseShadow.soft.y)
    }
    func pulseCardShadow() -> some View {
        shadow(color: PulseShadow.card.color,
               radius: PulseShadow.card.radius,
               x: PulseShadow.card.x, y: PulseShadow.card.y)
    }
}

// MARK: - Type ramps used by V2
struct PulseType {
    static func display(_ size: CGFloat = 34) -> Font {
        .system(size: size, weight: .heavy, design: .default)
    }
    static func bigNumber(_ size: CGFloat = 44) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }
    static let eyebrow  = Font.system(size: 11, weight: .bold, design: .default)
    static let cardTitle = Font.system(size: 17, weight: .bold, design: .default)
    static let bodyMuted = Font.system(size: 13, weight: .medium, design: .default)
    static let cta       = Font.system(size: 13, weight: .semibold, design: .default)
}

// MARK: - Eyebrow label (the "01 · Su" style tag)
struct PulseEyebrow: View {
    let text: String
    let color: Color
    var body: some View {
        Text(text.uppercased())
            .font(PulseType.eyebrow)
            .tracking(0.6)
            .foregroundStyle(color)
    }
}
