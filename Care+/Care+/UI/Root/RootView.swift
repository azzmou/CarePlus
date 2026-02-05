import SwiftUI

struct RootView: View {
    @Bindable var state: AppState

    var body: some View {
        Group {
            if state.currentUser == nil && !state.isGuest {
                AuthLandingView(state: state)

            // 🔒 BLOCCO TEMP: salta scelta ruolo + setup wizard + server gating
            } else if state.bloccoScelta {
                MainTabView(state: state)

            // ⬇️ Flusso normale (quando disattivi bloccoScelta)
            } else if state.needsSetupWizard {
                NavigationStack {
                    SetupWizardView()
                }
                .environment(state)

            } else if !state.hasSeenEducation {
                EducationOnboardingCompactView(state: state)

            } else if !state.hasCompletedOnboarding {
                OnboardingPermissionsView(state: state)

            } else {
                MainTabView(state: state)
            }
        }
        .onAppear {
            state.load()
            NotificationManager.requestAuthorization()
        }
    }
}
