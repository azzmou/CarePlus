import SwiftUI

// This extension aligns older dark-only naming with the new unified AppTheme palette.
// It prevents type ambiguity and avoids hardcoded colors in Views.
extension AppTheme {
    // Backwards-compat mapping (do NOT introduce new colors)
    public static var darkBackground: Color { Self.background }
    public static var darkCard: Color { Self.surface }
    public static var accentTeal: Color { Self.primary }
    public static var warningYellow: Color { Self.secondary }
    public static var textOnDarkPrimary: Color { Self.textPrimary }
    public static var textOnDarkTertiary: Color { Self.textSecondary }
    public static var strokeOnDark: Color { Self.secondary.opacity(0.12) }
}

