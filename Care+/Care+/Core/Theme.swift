//
//  Theme.swift
//  Care+
//
//  Legacy compatibility mapping for AppTheme (avoid redefining the type)
//

import SwiftUI
import UIKit

// Questo layer deve SOLO rimappare nomi vecchi -> palette unica (AppTheme).
// Niente colori hardcoded “lavanda/viola”, altrimenti la light mode resta rotta.
extension AppTheme {

    // MARK: - Core (legacy aliases)
    public static var primaryLegacy: Color { Self.primary }
    public static var textOnDark: Color { Self.textPrimary }
    public static var textOnDarkSecondary: Color { Self.textSecondary }

    // MARK: - Surfaces (legacy aliases)
    public static var card: Color { Self.surface }

    // MARK: - Status (legacy aliases)
    public static var successLegacy: Color { Self.success }

    // MARK: - Dark palette (legacy aliases)
    public static var backgroundDark: Color { Self.background }
    public static var containerDark: Color { Self.surface }
    public static var iconDark: Color { Self.primary }

    // MARK: - Gradient legacy -> map to background for coherence
    public static var gradientTop: Color { Self.background }
    public static var gradientBottom: Color { Self.background }

    // MARK: - Light palette (legacy aliases)
    // ✅ NIENTE LAVANDA/VIOLA: tutto rimappato alla palette unica AppTheme.
    public static var backgroundLight: Color { Self.background }
    public static var containerLight: Color { Self.surface }
    public static var iconLight: Color { Self.primary }

    // Se qualche view usa ancora questo, rimappalo a primary soft invece di lavanda
    public static var lavenderButtonLight: Color { Self.primary.opacity(0.16) }

    // MARK: - Glass overlays (dynamic, coherent in light & dark)
    public static var glassStroke: Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor(white: 1.0, alpha: 0.14)
            : UIColor(white: 0.0, alpha: 0.10)
        })
    }

    public static var glassFill: Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor(white: 1.0, alpha: 0.08)
            : UIColor(white: 0.0, alpha: 0.04)
        })
    }
}
