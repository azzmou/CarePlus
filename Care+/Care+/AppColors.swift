import SwiftUI

// AppColors: unica palette di colori dell'app (Light Mode vincolante)
enum AppColors {
    // Palette base (Light)
    static let background: Color = Color(.sRGB, red: 244/255, green: 246/255, blue: 245/255, opacity: 1) // #F4F6F5
    static let surface: Color = .white // #FFFFFF

    // Accenti
    static let primary: Color = Color(.sRGB, red: 48/255, green: 124/255, blue: 122/255, opacity: 1) // #307C7A
    static let secondary: Color = Color(.sRGB, red: 223/255, green: 183/255, blue: 72/255, opacity: 1) // #DFB748

    // Testi
    static let textPrimary: Color = .black
    static let textSecondary: Color = .black.opacity(0.55)

    // Stato/disabled
    static let disabled: Color = .black.opacity(0.25)
}
