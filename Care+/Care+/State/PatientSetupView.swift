import SwiftUI
import Observation
import Supabase

struct PatientSetupView: View {
    @Environment(AppState.self) private var app

    @State private var birthYear: String = ""
    @State private var notes: String = ""
    @State private var caregiverEmail: String = ""

    @State private var isSubmitting = false
    @State private var error: String? = nil

    var body: some View {
        Form {
            Section("Patient details") {
                TextField("Birth year", text: $birthYear)
                    .keyboardType(.numberPad)

                TextField("Notes (optional)", text: $notes)
            }

            Section("Caregiver") {
                TextField("Caregiver email", text: $caregiverEmail)
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
        .navigationTitle("Patient setup")
    }

    @MainActor
    private func submitAsync() async {
        guard let session = await AuthService.shared.currentSession() else {
            error = "Not authenticated"
            return
        }

        let patientId = session.user.id.uuidString

        guard let by = Int(birthYear), by > 1900, by < 2100 else {
            error = "Enter a valid birth year"
            return
        }

        let email = caregiverEmail.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !email.isEmpty else {
            error = "Enter caregiver email"
            return
        }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            // 1) Save patient details
            try await DetailsService.shared.upsertPatientDetails(
                birthYear: by,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes
            )

            // 2) Resolve caregiver id by email via RPC (bypasses RLS safely)
            let caregiverId = try await ProfilesService.shared.getProfileIdByEmail(email)
            guard let caregiverId else {
                error = "Caregiver not found"
                return
            }

            // 3) Create care link
            try await CareLinksService.shared.createLink(
                patientId: patientId,
                caregiverId: caregiverId,
                status: "active"
            )

            // 4) Activate profile (CHECK wants active + role not null; role already set in RoleChoice)
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
