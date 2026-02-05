import SwiftUI
import Observation

struct SetupWizardView: View {
    @Environment(AppState.self) private var app
    @State private var isRefreshing = false
    @State private var error: String? = nil

    private var roleLower: String {
        (app.userRole ?? "").lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        Group {
            if roleLower == "patient" {
                PatientSetupView()
            } else if roleLower == "caregiver" {
                CaregiverSetupView()
            } else {
                VStack(spacing: 12) {
                    Text("Loading role…")
                        .foregroundStyle(AppTheme.textSecondary)

                    if isRefreshing {
                        ProgressView()
                    }

                    if let error {
                        Text(error)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        Task { await refreshRole() }
                    } label: {
                        Text("Retry")
                            .font(.headline.weight(.semibold))
                    }
                    .padding(.top, 6)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Account setup")
        .task {
            // se ci arrivi qui e userRole non è pronto, fai refresh subito
            if app.userRole == nil {
                await refreshRole()
            }
        }
    }

    @MainActor
    private func refreshRole() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        error = nil
        defer { isRefreshing = false }

        await app.refreshProfileFromSupabase()

        if app.userRole == nil {
            error = "Role not loaded. Check profile row / RLS."
        }
    }
}
