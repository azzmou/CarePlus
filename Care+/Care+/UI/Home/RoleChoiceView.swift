import SwiftUI
import Observation

struct RoleChoiceView: View {
    @Environment(AppState.self) private var app
    @State private var isSubmitting = false
    @State private var error: String? = nil

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Choose your role")
                    .font(.title.weight(.bold))
                    .foregroundColor(AppTheme.textPrimary)

                Text("Please choose your role to continue.")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }

            // UI: User — DB: patient
            PrimaryButton("I'm a User", color: AppTheme.primary) {
                Task { await select(role: "patient") }
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .disabled(isSubmitting)

            PrimaryButton("I'm a Caregiver", color: AppTheme.primary) {
                Task { await select(role: "caregiver") }
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .disabled(isSubmitting)

            if isSubmitting {
                ProgressView()
                    .padding(.top, 16)
            }

            if let error = error {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Role")
    }

    private func select(role: String) async {
        guard !isSubmitting else { return }
        isSubmitting = true
        error = nil
        defer { isSubmitting = false }

        do {
            try await ProfilesService.shared.setRoleOnce(role)
            await app.refreshProfileFromSupabase()
        } catch {
            self.error = error.localizedDescription
        }
    }
}
