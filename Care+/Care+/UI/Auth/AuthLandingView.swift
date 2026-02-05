//
//  AuthLandingView.swift
//  Care+
//

import SwiftUI
import AuthenticationServices

struct AuthLandingView: View {
    @Bindable var state: AppState

    @State private var showLogin = false
    @State private var showSignUpFlow = false
    @StateObject private var appleAuth = AppleSignInCoordinator()
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Screen {
            VStack(spacing: 22) {

                // MARK: - Header (Logo)
                VStack(spacing: 0) {
                    Image("logonome")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .padding(.bottom, 24)
                        .accessibilityLabel("Alzheimer Care")
                }

                // MARK: - Welcome text
                VStack(alignment: .leading, spacing: 6) {
                    Text("Hello!")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("Nice to meet you.")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 28)

                // MARK: - Actions
                VStack(spacing: 12) {

                    // ✅ Login (full width)
                    AuthPrimaryCTA(
                        title: "Login",
                        fill: AppTheme.primary
                    ) {
                        showLogin = true
                    }

                    // ✅ Create Account (full width)
                    AuthSecondaryCTA(
                        title: "Create Account"
                    ) {
                        showSignUpFlow = true
                    }

                    // ✅ Continue as Guest
                    Button {
                        state.setGuest(true)
                    } label: {
                        Text("Continue as Guest")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                    }
                    .background(AppTheme.surface.opacity(0.75))
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(AppTheme.textPrimary.opacity(0.08), lineWidth: 1)
                    )
                    .shadow(radius: 10, y: 6)
                    .accessibilityLabel("Continue as Guest")

                    Text("or continue with")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                        .padding(.top, 6)

                    // ✅ Sign in with Apple
                    SignInWithAppleButton(.signUp) { request in
                        appleAuth.configure(request: request)
                    } onCompletion: { result in
                        appleAuth.handle(result: result) { profile in
                            state.currentUser = profile
                            state.saveUser()
                        }
                    }
                    .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                    .frame(height: 52)
                    .clipShape(Capsule())

                    // ✅ Google
                    GoogleButton {
                        signInWithGoogle { profile in
                            guard let profile else { return }
                            state.currentUser = profile
                            state.saveUser()
                        }
                    }
                }
                .padding(.horizontal, 28)

                // MARK: - Footer
                Text("By creating an account, you agree to our\nTerms of Service and Privacy Policy.")
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.textSecondary.opacity(0.85))
                    .padding(.bottom, 14)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .sheet(isPresented: $showLogin) {
            LoginFormView(state: state, mode: .login)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showSignUpFlow) {
            SignUpFlowView(state: state)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Custom CTAs (full width, like Apple / Google)

private struct AuthPrimaryCTA: View {
    let title: String
    let fill: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
        }
        .background(fill)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(radius: 10, y: 6)
        .accessibilityLabel(title)
    }
}

private struct AuthSecondaryCTA: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
        }
        .background(AppTheme.surface.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(AppTheme.textPrimary.opacity(0.08), lineWidth: 1)
        )
        .shadow(radius: 10, y: 6)
        .accessibilityLabel(title)
    }
}

