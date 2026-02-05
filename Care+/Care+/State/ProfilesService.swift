import Foundation
import Supabase

struct ProfileRowDTO: Codable, Sendable {
    let id: String
    let status: String
    let role: String?
    let display_name: String?
    let email: String?
}

struct ProfileUpsertDTO: Encodable, Sendable {
    let id: String
    let status: String?
    let role: String?
    let display_name: String?
    let email: String?
}

@MainActor
final class ProfilesService {
    static let shared = ProfilesService()
    private init() {}

    private var client: SupabaseClient { SupabaseClientProvider.shared.client }

    func fetchProfile() async throws -> ProfileRowDTO? {
        guard let session = await AuthService.shared.currentSession() else { return nil }
        let userId = session.user.id.uuidString

        let rows: [ProfileRowDTO] = try await client
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .limit(1)
            .execute()
            .value

        return rows.first
    }

    func upsertProfile(_ dto: ProfileUpsertDTO) async throws {
        _ = try await client
            .from("profiles")
            .upsert(dto, onConflict: "id")
            .execute()
    }

    /// Set role only once (RoleChoiceView).
    /// IMPORTANT: role must be "patient" or "caregiver" (DB enum).
    func setRoleOnce(_ role: String) async throws {
        guard let session = await AuthService.shared.currentSession() else { return }
        let userId = session.user.id.uuidString

        let normalized = role.lowercased()
        guard normalized == "patient" || normalized == "caregiver" else {
            throw NSError(domain: "ProfilesService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid role: \(role)"])
        }

        let existing = try? await fetchProfile()
        if let existingRole = existing?.role, !existingRole.isEmpty {
            return
        }

        struct Upsert: Encodable {
            let id: String
            let role: String
            let status: String
        }

        // Keep pending so SetupWizard can run.
        let payload = Upsert(id: userId, role: normalized, status: "pending")

        _ = try await client
            .from("profiles")
            .upsert(payload, onConflict: "id")
            .execute()
    }

    // MARK: - RPC: resolve id by email safely (bypass RLS through SECURITY DEFINER)

    struct GetIdResponse: Decodable {
        let id: String?
    }

    func getProfileIdByEmail(_ email: String) async throws -> String? {
        // expects RPC: get_profile_id_by_email(email text) returns uuid
        let res: [GetIdResponse] = try await client
            .rpc("get_profile_id_by_email", params: ["p_email": email])
            .execute()
            .value
        return res.first?.id
    }
}
