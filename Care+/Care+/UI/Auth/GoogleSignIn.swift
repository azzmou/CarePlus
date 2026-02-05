//
//  GoogleSignIn.swift
//  Care+
//
//  Compiles even if GoogleSignIn package is not installed
//

import SwiftUI
import UIKit

#if canImport(GoogleSignIn)
import GoogleSignIn
#endif

struct GoogleButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "g.circle.fill")
                    .foregroundStyle(.black.opacity(0.75))
                Text("Sign in with Google")
                    .font(.headline)
                    .foregroundStyle(.black)
            }
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(Color.white)
            .clipShape(Capsule())
        }
    }
}

@MainActor
func signInWithGoogle(onComplete: @escaping (UserProfile?) -> Void) {
#if canImport(GoogleSignIn)
    guard let root = UIApplication.shared.connectedScenes
        .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController })
        .first else {
        onComplete(nil)
        return
    }

    // TODO: configure your clientID
    let clientID = ""
    guard !clientID.isEmpty else {
        onComplete(nil)
        return
    }

    let config = GIDConfiguration(clientID: clientID)
    GIDSignIn.sharedInstance.configuration = config

    GIDSignIn.sharedInstance.signIn(withPresenting: root) { result, error in
        guard error == nil, let user = result?.user else { onComplete(nil); return }
        let name = user.profile?.name ?? "Google User"
        let email = user.profile?.email ?? ""
        onComplete(UserProfile(name: name, phone: "", email: email, provider: "google"))
    }
#else
    onComplete(nil)
#endif
}
