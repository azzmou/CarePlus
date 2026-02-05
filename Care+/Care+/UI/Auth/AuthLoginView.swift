import SwiftUI
import Supabase

struct AuthLoginView: View {
    @Bindable var state: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    @State private var showResetPassword = false
    @State private var showRecoverEmailInfo = false
    @State private var resetEmail: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        Screen {
            VStack(alignment: .leading, spacing: 12) {
                Text("Sign In")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(AppTheme.textPrimary)

                VStack(spacing: 10) {
                    AuthTextField(title: "Email address", text: $email)
                        .keyboardType(.emailAddress)
                    AuthTextField(title: "Password", text: $password, isSecure: true)

                    HStack {
                        Spacer()
                        Button("Forgot password?") {
                            resetEmail = email
                            showResetPassword = true
                        }
                        .font(.footnote)
                        .foregroundStyle(AppTheme.primary)
                        .underline()
                    }
                    .padding(.top, 4)
                }

                PrimaryPillButton(isLoading ? "Signing In…" : "Sign In") {
                    Task { await login() }
                }
                .disabled(isLoading || email.isEmpty || password.isEmpty)

                if errorMessage != nil {
                    Text("Invalid login credentials").font(.footnote).foregroundStyle(.red)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle("")
        .toolbarTitleDisplayMode(.inline)
        .sheet(isPresented: $showResetPassword) {
            VStack(spacing: 16) {
                Text("Reset password").font(.title2).bold().foregroundStyle(AppTheme.textPrimary)

                Text("Enter your email and we'll send a reset link.")
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)

                TextField("Email address", text: $resetEmail)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(.roundedBorder)

                Button("Send link") {
                    Task {
                        do {
                            guard !resetEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                                alertMessage = "Enter a valid email address."
                                showAlert = true
                                return
                            }
                            try await AuthService.shared.sendPasswordReset(email: resetEmail)
                            alertMessage = "If an account exists, we sent a reset link to your email."
                            showAlert = true
                            showResetPassword = false
                        } catch {
                            alertMessage = "We couldn't send the reset link. Try again."
                            showAlert = true
                        }
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("Close") { showResetPassword = false }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .sheet(isPresented: $showRecoverEmailInfo) {
            VStack(spacing: 16) {
                Text("Find your email").font(.title2).bold().foregroundStyle(AppTheme.textPrimary)

                Text("""
Try these steps:
• Check your welcome emails
• Try your usual addresses
• Ask your caregiver or contact support
""")
                .multilineTextAlignment(.leading)
                .foregroundStyle(AppTheme.textSecondary)

                Button("Done") { showRecoverEmailInfo = false }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
        .alert("Notice", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    @MainActor
    private func login() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            _ = try await AuthService.shared.signIn(email: email, password: password)
            await state.loadSupabaseSession()
            // Removed dismiss() to avoid skipping post-login flow
        } catch {
            errorMessage = "Invalid login credentials"
        }
    }
}

