import SwiftUI

@main
struct Care_App: App {
    @State private var state = AppState()
    @StateObject private var appearance = AppearanceSettings()

    var body: some Scene {
        WindowGroup {
            AuthGateView(state: state)
                .environmentObject(appearance)
                .preferredColorScheme(appearance.selected.colorScheme)
                .tint(AppTheme.primary)
                .background(AppTheme.background.ignoresSafeArea())
        }
    }
}
