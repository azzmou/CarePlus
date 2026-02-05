import Foundation
import Supabase

struct ProfileDTO: Codable, Equatable {
    let id: UUID
    let role: String?
    let status: String
    let display_name: String?
}

@MainActor
final class ProfilesService {
    static let shared = ProfilesService()
    private let client = SupabaseClientProvider.shared.client
    private init() {}

    func fetchMyProfile() async throws -> ProfileDTO? {
        // Select minimal columns and filter by auth.uid()
        // Using RPC auth.uid() is not directly supported in query builder; leverage RLS with eq to current user id
        // Fetch current user id from auth.session
        guard let session = try? await client.auth.session else { return nil }
        let userId = session.user.id
        struct Row: Decodable { let id: UUID; let role: String?; let status: String; let display_name: String? }
        let rows: [Row] = try await client
            .from("profiles")
            .select("id, role, status, display_name")
            .eq("id", value: userId)
            .limit(1)
            .execute()
            .value
        guard let row = rows.first else { return nil }
        return ProfileDTO(id: row.id, role: row.role, status: row.status, display_name: row.display_name)
    }

    func setRoleOnce(role: String) async throws -> ProfileDTO {
        // Update the current user's profile role and set status to active, returning the updated row
        guard let session = try? await client.auth.session else {
            throw NSError(domain: "ProfilesService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No auth session"])
        }
        let userId = session.user.id
        struct UpdatePayload: Encodable { let role: String; let status: String }
        let payload = UpdatePayload(role: role, status: "active")
        struct Row: Decodable { let id: UUID; let role: String?; let status: String; let display_name: String? }
        let rows: [Row] = try await client
            .from("profiles")
            .update(payload)
            .eq("id", value: userId)
            .select("id, role, status, display_name")
            .limit(1)
            .execute()
            .value
        guard let row = rows.first else {
            throw NSError(domain: "ProfilesService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Profile not found after update"])
        }
        return ProfileDTO(id: row.id, role: row.role, status: row.status, display_name: row.display_name)
    }
}
