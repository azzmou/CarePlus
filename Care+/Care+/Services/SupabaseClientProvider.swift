import Foundation
import Supabase

enum SupabaseConfig {
    static let url = URL(string: "https://dtlpfujnckiclianzhmo.supabase.co")!
    static let anonKey = "sb_publishable_tRD2QP3aq9nlq7Rze_xSpQ_O48lAT8a"
}

final class SupabaseClientProvider {
    static let shared = SupabaseClientProvider()
    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: SupabaseConfig.url,
            supabaseKey: SupabaseConfig.anonKey,
            options: .init(
                auth: .init(
                    // Opt-in to emitting the locally stored session as the initial session to avoid the warning from AuthClient
                    emitLocalSessionAsInitialSession: true
                )
            )
        )
    }
}
