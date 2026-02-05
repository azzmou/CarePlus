import Foundation
import Observation

@MainActor
@Observable
final class SessionStore {
    var isLoggedIn: Bool = false
    var email: String = ""
}
