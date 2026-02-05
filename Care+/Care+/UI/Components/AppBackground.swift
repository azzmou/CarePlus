import SwiftUI

struct AppBackground: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        AppTheme.background
            .overlay(
                // leggerissimo lift in dark (coerente col look “calmo”)
                Group {
                    if scheme == .dark {
                        RadialGradient(
                            colors: [
                                AppTheme.secondary.opacity(0.06),
                                Color.clear
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 320
                        )
                    } else {
                        Color.clear
                    }
                }
            )
            .ignoresSafeArea()
    }
}
