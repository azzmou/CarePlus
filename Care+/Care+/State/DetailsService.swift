import Foundation
import Supabase

struct PatientDetailsDTO: Codable, Sendable {
    let patient_id: String
    let birth_year: Int
    let notes: String?
}

struct CaregiverDetailsDTO: Codable, Sendable {
    let caregiver_id: String
    let full_name: String
    let phone: String?
    let relationship: String?
}

@MainActor
final class DetailsService {
    static let shared = DetailsService()
    private init() {}

    private var client: SupabaseClient { SupabaseClientProvider.shared.client }

    // MARK: - Upsert

    func upsertPatientDetails(birthYear: Int, notes: String?) async throws {
        guard let session = await AuthService.shared.currentSession() else { return }
        let userId = session.user.id.uuidString  // String

        struct Upsert: Encodable {
            let patient_id: String
            let birth_year: Int
            let notes: String?
        }

        let payload = Upsert(patient_id: userId, birth_year: birthYear, notes: notes)

        _ = try await client.database
            .from("patient_details")
            .upsert(payload, onConflict: "patient_id")
            .execute()
    }

    func upsertCaregiverDetails(fullName: String, phone: String?, relationship: String?) async throws {
        guard let session = await AuthService.shared.currentSession() else { return }
        let userId = session.user.id.uuidString  // String

        struct Upsert: Encodable {
            let caregiver_id: String
            let full_name: String
            let phone: String?
            let relationship: String?
        }

        let payload = Upsert(
            caregiver_id: userId,
            full_name: fullName,
            phone: phone,
            relationship: relationship
        )

        _ = try await client.database
            .from("caregiver_details")
            .upsert(payload, onConflict: "caregiver_id")
            .execute()
    }

    // MARK: - Fetch

    func fetchPatientDetails(patientId: String) async throws -> PatientDetailsDTO? {
        let rows: [PatientDetailsDTO] = try await client.database
            .from("patient_details")
            .select()
            .eq("patient_id", value: patientId) // String
            .execute()
            .value

        return rows.first
    }

    func fetchCaregiverDetails(caregiverId: String) async throws -> CaregiverDetailsDTO? {
        let rows: [CaregiverDetailsDTO] = try await client.database
            .from("caregiver_details")
            .select()
            .eq("caregiver_id", value: caregiverId) // String
            .execute()
            .value

        return rows.first
    }
}
