//
//  LoginFormView.swift
//  Care+
//

import SwiftUI

struct LoginFormView: View {
    enum Mode { case login, register }

    @Bindable var state: AppState
    let mode: Mode

    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showErrors = false
    @State private var isCaregiver: Bool = false
    @State private var useUsernameInsteadOfEmail: Bool = false
    @State private var showingForgotPasswordAlert: Bool = false
    @State private var showingForgotEmailAlert: Bool = false

    @Environment(\.dismiss) private var dismiss

    private var nameOK: Bool { Validators.nonEmpty(name) }
    private var phoneOK: Bool { Validators.isValidPhone(phone) }
    private var emailOK: Bool { useUsernameInsteadOfEmail ? true : Validators.isValidEmail(email) }
    private var usernameOK: Bool { useUsernameInsteadOfEmail ? Validators.nonEmpty(email) : true }
    private var passwordOK: Bool { password.count >= 6 }

    private var canContinue: Bool {
        if mode == .login {
            return (useUsernameInsteadOfEmail ? usernameOK : emailOK) && passwordOK
        } else {
            return nameOK && phoneOK && emailOK && passwordOK
        }
    }

    var body: some View {
        ZStack {
            // ✅ background coerente sempre, indipendente da AppBackground
            AppTheme.background.ignoresSafeArea()

            VStack(spacing: 16) {
                Text(mode == .login ? "Login" : "Create Account")
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(AppTheme.textPrimary)
                    .padding(.top, 18)

                CardDark {
                    if mode == .register {
                        LabeledField(label: "Name (required)", placeholder: "Full name", text: $name)
                        if showErrors && !nameOK { err("Name is required.") }

                        LabeledField(label: "Phone (required)", placeholder: "+39 333 123 4567", text: $phone, keyboard: .phonePad)
                        if showErrors && !phoneOK { err("Invalid phone: use 8–15 digits.") }

                        LabeledField(label: "Email (required)", placeholder: "name@email.com", text: $email, keyboard: .emailAddress)
                        if showErrors && !emailOK { err("Invalid email format.") }

                        LabeledField(label: "Password (min 6)", placeholder: "Password", text: $password, isSecure: true)
                        if showErrors && !passwordOK { err("Password must be at least 6 chars.") }

                        Divider()
                            .overlay(AppTheme.secondary.opacity(0.18))

                        Text("Role")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)

                        Picker("Role", selection: $isCaregiver) {
                            Text("User").tag(false)
                            Text("Caregiver").tag(true)
                        }
                        .pickerStyle(.segmented)
                        .tint(AppTheme.primary)

                        Text(isCaregiver
                             ? "You will have access to caregiver features (e.g., Safety & Tracking)."
                             : "You will use the app as a user."
                        )
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                    }

                    if mode == .login {
                        Toggle(isOn: $useUsernameInsteadOfEmail) {
                            Text("Use username instead of email")
                                .foregroundStyle(AppTheme.textPrimary)
                        }
                        .tint(AppTheme.primary)

                        LabeledField(
                            label: useUsernameInsteadOfEmail ? "Username (required)" : "Email (required)",
                            placeholder: useUsernameInsteadOfEmail ? "your_username" : "name@email.com",
                            text: $email,
                            keyboard: useUsernameInsteadOfEmail ? .default : .emailAddress
                        )

                        if showErrors && useUsernameInsteadOfEmail && !usernameOK { err("Username is required.") }
                        if showErrors && !useUsernameInsteadOfEmail && !emailOK { err("Invalid email format.") }

                        LabeledField(label: "Password (min 6)", placeholder: "Password", text: $password, isSecure: true)
                        if showErrors && !passwordOK { err("Password must be at least 6 chars.") }

                        HStack {
                            Button {
                                showingForgotPasswordAlert = true
                            } label: {
                                Text("Forgot password?")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.primary)
                            }

                            Spacer()

                            Button {
                                showingForgotEmailAlert = true
                            } label: {
                                Text("Forgot email?")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.primary)
                            }
                        }
                    }

                    // ✅ bottone coerente con palette (usa PrimaryButton corretto)
                    PrimaryButton(mode == .login ? "CONTINUE" : "REGISTER",
                                  style: .filled,
                                  color: AppTheme.primary,
                                  isEnabled: canContinue) {
                        if !canContinue { showErrors = true; return }

                        if mode == .login {
                            Task {
                                do {
                                    _ = try await AuthService.shared.signIn(email: email, password: password)
                                    await state.loadSupabaseSession()
                                    dismiss()
                                } catch {
                                    // mostra errore in UI (es: errorMessage = error.localizedDescription)
                                    print("Login error:", error)
                                }
                            }
                        } else {
                            Task {
                                do {
                                    _ = try await AuthService.shared.signUp(email: email, password: password)
                                    await state.loadSupabaseSession()
                                    dismiss()
                                } catch {
                                    print("Signup error:", error)
                                }
                            }
                        }
                    }
                }
                .alert("Password recovery", isPresented: $showingForgotPasswordAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("We will guide you to recover your password in the next version. For now, please contact support.")
                }
                .alert("Email recovery", isPresented: $showingForgotEmailAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("We will guide you to recover your email/username in the next version. For now, please contact support.")
                }

                Spacer()
            }
            .padding(.horizontal, 18)
        }
    }

    private func err(_ s: String) -> some View {
        Text(s)
            .font(.caption)
            .foregroundStyle(.red)
    }
}

