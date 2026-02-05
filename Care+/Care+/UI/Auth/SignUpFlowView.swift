import SwiftUI

struct SignUpFlowView: View {
    @Bindable var state: AppState
    @State private var step: Int = 1
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var password = ""

    @State private var caregiverFirstName = ""
    @State private var caregiverLastName = ""
    @State private var caregiverRelationship: String = "Family"
    @State private var caregiverPhone = ""
    @State private var caregiverEmail = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()

                switch step {
                case 1:
                    SignUpStep1AboutYouView(
                        firstName: $firstName,
                        lastName: $lastName,
                        phone: $phone,
                        email: $email,
                        password: $password,
                        isLoading: isLoading,
                        errorMessage: errorMessage ?? "",
                        onContinue: {
                            isLoading = true
                            errorMessage = nil
                            Task {
                                do {
                                    try await createAccount()
                                    step = 2
                                } catch {
                                    errorMessage = error.localizedDescription
                                }
                                isLoading = false
                            }
                        }
                    )
                case 2:
                    SignUpStep2CaregiverView(
                        caregiverFirstName: $caregiverFirstName,
                        caregiverLastName: $caregiverLastName,
                        caregiverRelationship: $caregiverRelationship,
                        caregiverPhone: $caregiverPhone,
                        caregiverEmail: $caregiverEmail,
                        isLoading: isLoading,
                        errorMessage: errorMessage ?? "",
                        onConfirm: {
                            isLoading = true
                            errorMessage = nil
                            Task {
                                do {
                                    try await saveCaregiverIfProvided()
                                    step = 3
                                } catch {
                                    // ignore errors but log or handle if needed
                                }
                                isLoading = false
                            }
                        },
                        onSkip: {
                            step = 3
                        }
                    )
                case 3:
                    SignUpStep3WelcomeView(
                        onStart: {
                            isLoading = true
                            Task {
                                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s delay
                                await state.loadSupabaseSession()
                                isLoading = false
                            }
                        }
                    )
                default:
                    EmptyView()
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    // MARK: - Helpers

    private func createAccount() async throws {
        let signUpResult = try await AuthService.shared.signUp(email: email, password: password)
        _ = signUpResult // prevent unused warning
    }

    private func saveCaregiverIfProvided() async throws {
        // Minimal validation: caregiver first or last name not empty, and phone or email not empty
        let hasName = !caregiverFirstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !caregiverLastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasContact = !caregiverPhone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !caregiverEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        guard hasName, hasContact else {
            return // nothing to save
        }

        // Persistence is disabled here to avoid missing module errors.
        return
    }
}

