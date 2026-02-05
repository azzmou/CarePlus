import SwiftUI

struct AuthFinalWelcomeView: View {
    @Bindable var state: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Screen {
            VStack(spacing: 24) {
                Text("Welcome! Every memory matters.")
                    .font(.title.weight(.bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.textPrimary)

                PrimaryPillButton("Continue") {
                    dismiss()
                }
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("")
        .toolbarTitleDisplayMode(.inline)
    }
}
