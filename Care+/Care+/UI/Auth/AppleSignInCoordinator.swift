//
//  AppleSignInCoordinator.swift
//  Care+
//

import Foundation
import Combine
import AuthenticationServices

@MainActor
final class AppleSignInCoordinator: NSObject, ObservableObject {

    func configure(request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }

    func handle(result: Result<ASAuthorization, Error>, onSuccess: (UserProfile) -> Void) {
        switch result {
        case .failure:
            break
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential else { return }

            let given = credential.fullName?.givenName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let family = credential.fullName?.familyName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let fullName = ([given, family].filter { !$0.isEmpty }).joined(separator: " ")
            let email = credential.email ?? ""

            let name = fullName.isEmpty ? "Apple User" : fullName

            let profile = UserProfile(
                name: name,
                phone: "",
                email: email,
                provider: "apple"
            )
            onSuccess(profile)
        }
    }
}
