import SwiftUI

/// UNICO AppTheme: all colors used in Views should come from here.
///
/// Provides adaptive tokens for both light and dark modes.
/// Maps to existing AppColors for light mode and custom palette for dark mode.
/// Also exposes compatibility aliases for legacy code.
public enum AppTheme {
    // MARK: - Palette Definition
    
    private struct Palette {
        let background: Color
        let surface: Color
        let surface2: Color
        let stroke: Color
        let shadow: Color
        let textPrimary: Color
        let textSecondary: Color
        let primary: Color
        let primaryMuted: Color
        let warning: Color
        let success: Color
        let danger: Color
        let secondary: Color
        let disabled: Color
    }
    
    // MARK: - Helper
    
    private static func hex(_ hex: Int, alpha: Double = 1) -> Color {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        return Color(red: red, green: green, blue: blue).opacity(alpha)
    }
    
    // MARK: - Light Palette
    
    private static var light: Palette {
        let warningColor = Color(red: 246/255, green: 200/255, blue: 102/255) // warm yellow
        let successColor = Color(red: 96/255, green: 187/255, blue: 120/255)  // green suited for light
        let dangerColor = Color(red: 210/255, green: 92/255, blue: 92/255)     // red suited for light
        
        let textSecondaryColor = AppColors.textSecondary
        let disabledColor = textSecondaryColor.opacity(0.6)
        
        return Palette(
            background: AppColors.background,
            surface: AppColors.surface,
            surface2: AppColors.surface.opacity(0.85),
            stroke: Color.black.opacity(0.12),
            shadow: Color.black.opacity(0.10),
            textPrimary: AppColors.textPrimary,
            textSecondary: textSecondaryColor,
            primary: AppColors.primary,
            primaryMuted: AppColors.primary.opacity(0.65),
            warning: warningColor,
            success: successColor,
            danger: dangerColor,
            secondary: AppColors.secondary,
            disabled: disabledColor
        )
    }
    
    // MARK: - Dark Palette
    
    private static var dark: Palette {
        let background = hex(0x0A1C1A)
        let surface = hex(0x0F2A27)
        let surface2 = hex(0x133430)
        let primary = hex(0x1FA39A)
        let primaryMuted = hex(0x1FA39A, alpha: 0.65)
        let warning = hex(0xE8C774)
        let success = hex(0x68C08D)
        let danger = hex(0xD26E6E)
        let textPrimary = hex(0xFFFFFF, alpha: 0.94)
        let textSecondary = hex(0xFFFFFF, alpha: 0.70)
        let stroke = hex(0xFFFFFF, alpha: 0.10)
        let shadow = Color.black.opacity(0.50)
        
        let secondary = primaryMuted
        let disabled = textSecondary.opacity(0.6)
        
        return Palette(
            background: background,
            surface: surface,
            surface2: surface2,
            stroke: stroke,
            shadow: shadow,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
            primary: primary,
            primaryMuted: primaryMuted,
            warning: warning,
            success: success,
            danger: danger,
            secondary: secondary,
            disabled: disabled
        )
    }
    
    // MARK: - Current Palette Selection
    
    private static var current: Palette {
        #if canImport(UIKit)
        switch UITraitCollection.current.userInterfaceStyle {
        case .dark:
            return dark
        default:
            return light
        }
        #else
        return light
        #endif
    }
    
    // MARK: - Public Tokens
    
    public static var background: Color { current.background }
    public static var surface: Color { current.surface }
    public static var surface2: Color { current.surface2 }
    public static var stroke: Color { current.stroke }
    public static var shadow: Color { current.shadow }
    public static var textPrimary: Color { current.textPrimary }
    public static var textSecondary: Color { current.textSecondary }
    public static var primary: Color { current.primary }
    public static var primaryMuted: Color { current.primaryMuted }
    public static var warning: Color { current.warning }
    public static var success: Color { current.success }
    public static var danger: Color { current.danger }
    public static var secondary: Color { current.secondary }
    public static var disabled: Color { current.disabled }
    
    // MARK: - Compatibility Aliases
    
    public static var textOnSurfaceSecondary: Color { textSecondary }
    public static var textOnSurfacePrimary: Color { textPrimary }
    public static var onSurface: Color { textPrimary }
    public static var surfaceBackground: Color { surface }
    public static var backgroundPrimary: Color { background }
}
