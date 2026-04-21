// PulseTheme.swift
// Design tokens for the Pulse onboarding (Momentum variant).
// Colors, typography, spacing, animation. Keep this in sync with
// the design source (Pulse Onboarding.html — Momentum).

import SwiftUI

// MARK: - Colors

extension Color {
    /// Primary coral accent — the Pulse brand color.
    static let pulseAccent        = Color(red: 1.00, green: 0.302, blue: 0.369) // #FF4D5E
    static let pulseAccentSoft    = Color(red: 1.00, green: 0.894, blue: 0.906) // #FFE4E7
    static let pulseAccentPressed = Color(red: 0.902, green: 0.200, blue: 0.278) // #E63347

    /// Neutral surfaces
    static let pulseBackground    = Color(red: 0.98, green: 0.98, blue: 0.98) // #FAFAFA
    static let pulseSurface       = Color.white
    static let pulseBackgroundDark = Color.black
    static let pulseSurfaceDark   = Color(red: 0.11, green: 0.11, blue: 0.12) // #1C1C1E

    /// Text
    static let pulseText           = Color(red: 0.04, green: 0.04, blue: 0.04) // #0A0A0A
    static let pulseTextSecondary  = Color(red: 0.235, green: 0.235, blue: 0.263, opacity: 0.6) // iOS systemSecondary

    /// Hero gradient colors (Momentum uses a radial wash)
    static let pulseHeroGradientStart  = Color(red: 1.00, green: 0.894, blue: 0.906) // #FFE4E7
    static let pulseHeroGradientMiddle = Color(red: 1.00, green: 0.961, blue: 0.965) // #FFF5F6
    static let pulseHeroGradientEnd    = Color(red: 0.98, green: 0.98, blue: 0.98) // #FAFAFA
}

// MARK: - Typography
// Using SF Pro (system). Sizes + weights pulled from the Momentum tokens.

enum PulseFont {
    static func title(_ size: CGFloat = 36) -> Font {
        .system(size: size, weight: .heavy, design: .default)
    }
    static func titleMedium() -> Font {
        .system(size: 32, weight: .heavy, design: .default)
    }
    static func body(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
    static func bodyBold(_ size: CGFloat = 17) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }
    static func caption(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
    /// Small uppercase wordmark style (PULSE)
    static let wordmark: Font = .system(size: 13, weight: .bold, design: .default)
}

// MARK: - Metrics

enum PulseMetrics {
    static let buttonHeight: CGFloat = 54
    static let buttonRadius: CGFloat = 16
    static let cardRadius: CGFloat   = 20
    static let horizontalPadding: CGFloat = 32
    static let footerBottomPadding: CGFloat = 42
}

// MARK: - Animation

enum PulseAnimation {
    static let springy: Animation = .spring(response: 0.45, dampingFraction: 0.75)
    static let easeOut: Animation = .easeOut(duration: 0.35)
    static let enterFade: Animation = .easeOut(duration: 0.6)
}
