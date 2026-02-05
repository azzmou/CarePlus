import SwiftUI

public struct UserDetails: Equatable {
    public var name: String
    public var surname: String
    public var phoneNumber: String
    public var email: String
    public var password: String
}

public struct OnboardingUserDetailsView: View {
    @State private var name: String = ""
    @State private var surname: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    @State private var password: String = ""

    public var onContinue: (UserDetails) -> Void

    public init(onContinue: @escaping (UserDetails) -> Void) {
        self.onContinue = onContinue
    }

    public var body: some View {
        ZStack {
            Color(hex: 0x3B0B66).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 24) {
                header
                fields
                Spacer(minLength: 16)
                continueButton
            }
            .padding(24)
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tell us")
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(.white)
            Text("about yourself.")
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(.white)
                .opacity(0.9)
        }
    }

    private var fields: some View {
        VStack(spacing: 14) {
            roundedField(text: $name, placeholder: "Name")
            roundedField(text: $surname, placeholder: "Surname")
            roundedField(text: $phoneNumber, placeholder: "+39 338 193 2451", keyboard: .phonePad)
            roundedField(text: $email, placeholder: "Email", keyboard: .emailAddress, textContentType: .emailAddress)
            roundedSecureField(text: $password, placeholder: "Password")
        }
    }

    private var continueButton: some View {
        Button(action: {
            onContinue(UserDetails(name: name, surname: surname, phoneNumber: phoneNumber, email: email, password: password))
        }) {
            Text("Continue")
                .font(.system(size: 18, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white.opacity(0.15))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .disabled(name.isEmpty || surname.isEmpty || email.isEmpty || password.isEmpty)
        .opacity((name.isEmpty || surname.isEmpty || email.isEmpty || password.isEmpty) ? 0.6 : 1)
    }

    private func roundedField(text: Binding<String>, placeholder: String, keyboard: UIKeyboardType = .default, textContentType: UITextContentType? = nil) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(keyboard)
            .textContentType(textContentType)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.12))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
    }

    private func roundedSecureField(text: Binding<String>, placeholder: String) -> some View {
        SecureField(placeholder, text: text)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.12))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .textInputAutocapitalization(.never)
    }
}

private extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}

#Preview {
    OnboardingUserDetailsView { details in
        print(details)
    }
}
