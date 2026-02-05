import SwiftUI

struct RoleSelectionView: View {
    @Bindable var state: AppState
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 24) {
            Text("Sei un paziente o un caregiver?")
                .font(.title.weight(.bold))
                .multilineTextAlignment(.center)

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 16) {
                PrimaryButton("Paziente", style: .filled, color: AppTheme.primary) {
                    select(role: "patient")
                }
                .disabled(isLoading)

                PrimaryButton("Caregiver", style: .soft, color: AppTheme.primary) {
                    select(role: "caregiver")
                }
                .disabled(isLoading)
            }

            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background.ignoresSafeArea())
    }

    private func select(role: String) {
        errorMessage = nil
        isLoading = true
        Task { @MainActor in
            do {
                _ = try await ProfilesService.shared.setRoleOnce(role: role)
                await state.refreshProfileFromSupabase()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

#Preview {
    RoleSelectionView(state: AppState())
}
