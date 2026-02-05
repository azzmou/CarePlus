import Foundation
import Supabase

struct CareLinkDTO: Codable, Sendable {
    let caregiver_id: String
    let patient_id: String
    let status: String
    let created_at: String?
}

@MainActor
final class CareLinksService {
    static let shared = CareLinksService()
    private init() {}

    private var client: SupabaseClient { SupabaseClientProvider.shared.client }

    // Crea link (patient crea link verso caregiverId) - status "active" in demo
    func createLink(patientId: String, caregiverId: String, status: String = "active") async throws {
        struct Insert: Encodable {
            let patient_id: String
            let caregiver_id: String
            let status: String
        }

        let payload = Insert(patient_id: patientId, caregiver_id: caregiverId, status: status)

        _ = try await client.database
            .from("care_links")
            .insert(payload)
            .execute()
    }

    // Lista caregivers del patient
    func fetchCaregivers(forPatientId patientId: String) async throws -> [CareLinkDTO] {
        let rows: [CareLinkDTO] = try await client.database
            .from("care_links")
            .select()
            .eq("patient_id", value: patientId)
            .execute()
            .value
        return rows
    }

    // Lista patients del caregiver
    func fetchPatients(forCaregiverId caregiverId: String) async throws -> [CareLinkDTO] {
        let rows: [CareLinkDTO] = try await client.database
            .from("care_links")
            .select()
            .eq("caregiver_id", value: caregiverId)
            .execute()
            .value
        return rows
    }

    // Prendi un link specifico (se esiste)
    func fetchLink(patientId: String, caregiverId: String) async throws -> CareLinkDTO? {
        let rows: [CareLinkDTO] = try await client.database
            .from("care_links")
            .select()
            .eq("patient_id", value: patientId)
            .eq("caregiver_id", value: caregiverId)
            .execute()
            .value
        return rows.first
    }
}
