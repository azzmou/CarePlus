import SwiftUI

struct AuthWelcomeView: View {
    @Environment(\.colorScheme) private var scheme
    @Bindable var state: AppState
    @State private var goLogin = false
    @State private var goSignUp = false

    var body: some View {
        Screen {
            VStack(spacing: 22) {
                VStack(spacing: 10) {
                    Image(scheme == .dark ? "Dark" : "Light")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 78, height: 78)

                    Text("Alzheimer\nCARE")
                        .font(.system(size: 34, weight: .black))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineSpacing(2)
                }
                .padding(.bottom, 10)

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

                VStack(spacing: 12) {
                    PrimaryPillButton("Login") { goLogin = true }
                    SecondaryPillButton("Create Account") { goSignUp = true }

                    Text("or continue with")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                        .padding(.top, 6)

                    HStack(spacing: 12) {
                        Button {
                            print("Apple Sign In UI tapped (not implemented)")
                        } label: {
                            HStack {
                                Image(systemName: "apple.logo")
                                Text("Apple")
                            }
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                        }
                        .background(AppTheme.surface)
                        .clipShape(Capsule())

                        Button {
                            print("Google Sign In UI tapped (not implemented)")
                        } label: {
                            HStack {
                                Image(systemName: "g.circle")
                                Text("Google")
                            }
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                        }
                        .background(AppTheme.surface)
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, 28)
                }
                .padding(.horizontal, 28)

                Text("By creating an account, you agree to our\nTerms of Service and Privacy Policy.")
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.textSecondary.opacity(0.85))
                    .padding(.bottom, 14)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationDestination(isPresented: $goLogin) {
                AuthLoginView(state: state)
            }
            .navigationDestination(isPresented: $goSignUp) {
                AuthSignUpView(state: state)
            }
        }
    }
}
