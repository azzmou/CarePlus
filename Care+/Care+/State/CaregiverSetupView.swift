import SwiftUI
import Observation
import Supabase

struct CaregiverSetupView: View {
    @Environment(AppState.self) private var app

    @State private var fullName: String = ""
    @State private var phone: String = ""
    @State private var relationship: String = ""
    @State private var patientEmail: String = ""

    @State private var isSubmitting = false
    @State private var error: String? = nil

    var body: some View {
        Form {
            Section("Caregiver details") {
                TextField("Full name", text: $fullName)

                TextField("Phone (optional)", text: $phone)
                    .keyboardType(.phonePad)

                TextField("Relationship (optional)", text: $relationship)
            }

            Section("Patient") {
                TextField("Patient email", text: $patientEmail)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            Button {
                Task { await submitAsync() }
            } label: {
                if isSubmitting { ProgressView() } else { Text("Save & Continue") }
            }
            .disabled(isSubmitting)

            if let error {
                Text(error).foregroundStyle(.red)
            }
        }
        .navigationTitle("Caregiver setup")
    }

    @MainActor
    private func submitAsync() async {
        guard let session = await AuthService.shared.currentSession() else {
            error = "Not authenticated"
            return
        }

        let caregiverId = session.user.id.uuidString

        guard !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            error = "Enter your full name"
            return
        }

        let email = patientEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !email.isEmpty else {
            error = "Enter patient email"
            return
        }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            // 1) Save caregiver details
            try await DetailsService.shared.upsertCaregiverDetails(
                fullName: fullName,
                phone: phone.isEmpty ? nil : phone,
                relationship: relationship.isEmpty ? nil : relationship
            )

            // 2) Resolve patient id by email via RPC
            let patientId = try await ProfilesService.shared.getProfileIdByEmail(email)
            guard let patientId else {
                error = "Patient not found"
                return
            }

            // 3) Create care link
            try await CareLinksService.shared.createLink(
                patientId: patientId,
                caregiverId: caregiverId,
                status: "active"
            )

            // 4) Activate profile
            try await setProfileStatusActive()
            await app.refreshProfileFromSupabase()

        } catch {
            self.error = error.localizedDescription
        }
    }

    @MainActor
    private func setProfileStatusActive() async throws {
        guard let session = await AuthService.shared.currentSession() else { return }
        let userId = session.user.id.uuidString

        struct Upsert: Encodable {
            let id: String
            let status: String
        }

        let payload = Upsert(id: userId, status: "active")

        _ = try await SupabaseClientProvider.shared.client.database
            .from("profiles")
            .upsert(payload, onConflict: "id")
            .execute()
    }
}
