import SwiftUI

struct AuthSignUpView: View {
    @Bindable var state: AppState
    @State private var name = ""
    @State private var surname = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var password = ""

    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var goCaregiver = false

    var body: some View {
        Screen {
            VStack(alignment: .leading, spacing: 16) {
                Text("Tell us about yourself")
                    .font(.title.weight(.bold))
                    .foregroundStyle(AppTheme.textPrimary)

                VStack(spacing: 12) {
                    AuthTextField(title: "Name", text: $name)
                    AuthTextField(title: "Surname", text: $surname)
                    AuthTextField(title: "Phone Number", text: $phone)
                        .keyboardType(.phonePad)
                    AuthTextField(title: "Email", text: $email)
                        .keyboardType(.emailAddress)
                    AuthTextField(title: "Password", text: $password, isSecure: true)
                }

                PrimaryPillButton(isLoading ? "Creating…" : "Continue") {
                    Task { await signUp() }
                }
                .disabled(isLoading || email.isEmpty || password.isEmpty)

                if let errorMessage { Text(errorMessage).font(.footnote).foregroundStyle(.red) }

                NavigationLink(destination: AuthCaregiverView(state: state), isActive: $goCaregiver) { EmptyView() }

                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle("")
        .toolbarTitleDisplayMode(.inline)
    }

    @MainActor
    private func signUp() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            _ = try await AuthService.shared.signUp(email: email, password: password)
            await state.loadSupabaseSession()
            // Fetch minimal profile if available (no upsert in current service)
            _ = try? await ProfilesService.shared.fetchProfile()
            goCaregiver = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
