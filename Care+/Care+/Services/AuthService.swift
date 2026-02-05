import Foundation
import Supabase

@MainActor
final class AuthService {
    static let shared = AuthService()
    private let client = SupabaseClientProvider.shared.client
    private init() {}

    func signUp(email: String, password: String) async throws -> Session? {
        let res = try await client.auth.signUp(email: email, password: password)
        return res.session // può essere nil se "Confirm Email" è ON
    }

    func signIn(email: String, password: String) async throws -> Session {
        let session = try await client.auth.signIn(email: email, password: password)
        return session
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    func currentSession() async -> Session? {
        try? await client.auth.session
    }
    
    func sendPasswordReset(email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }
}

