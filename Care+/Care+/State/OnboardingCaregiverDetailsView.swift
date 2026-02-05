import SwiftUI

public struct CaregiverDetails: Equatable {
    public var name: String
    public var surname: String
    public var typology: Typology
    public var phoneNumber: String
    public var email: String

    public enum Typology: String, CaseIterable, Identifiable {
        case family = "Family"
        case doctor = "Doctor"
        case friend = "Friend"
        case other = "Other"
        public var id: String { rawValue }
    }
}

public struct OnboardingCaregiverDetailsView: View {
    @State private var name: String = ""
    @State private var surname: String = ""
    @State private var typology: CaregiverDetails.Typology = .family
    @State private var phoneNumber: String = ""
    @State private var email: String = ""

    public var onConfirm: (CaregiverDetails) -> Void
    public var onSkip: () -> Void

    public init(onConfirm: @escaping (CaregiverDetails) -> Void, onSkip: @escaping () -> Void) {
        self.onConfirm = onConfirm
        self.onSkip = onSkip
    }

    public var body: some View {
        ZStack {
            Color(hex: 0x3B0B66).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 24) {
                header
                fields
                Spacer(minLength: 16)
                confirmButton
                skipButton
            }
            .padding(24)
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Who is")
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(.white)
            Text("your caregiver?")
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(.white)
                .opacity(0.9)
        }
    }

    private var fields: some View {
        VStack(spacing: 14) {
            roundedField(text: $name, placeholder: "Name")
            roundedField(text: $surname, placeholder: "Surname")
            pickerField
            roundedField(text: $phoneNumber, placeholder: "Phone Number", keyboard: .phonePad)
            roundedField(text: $email, placeholder: "Email", keyboard: .emailAddress, textContentType: .emailAddress)
        }
    }

    private var pickerField: some View {
        Menu {
            Picker("Typology", selection: $typology) {
                ForEach(CaregiverDetails.Typology.allCases) { t in
                    Text(t.rawValue).tag(t)
                }
            }
        } label: {
            HStack {
                Text(typology.rawValue)
                    .foregroundStyle(.white.opacity(0.9))
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var confirmButton: some View {
        Button(action: {
            onConfirm(CaregiverDetails(name: name, surname: surname, typology: typology, phoneNumber: phoneNumber, email: email))
        }) {
            Text("Confirm")
                .font(.system(size: 18, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white.opacity(0.15))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .disabled(name.isEmpty || surname.isEmpty)
        .opacity((name.isEmpty || surname.isEmpty) ? 0.6 : 1)
    }

    private var skipButton: some View {
        Button(action: onSkip) {
            Text("skip for now")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.white.opacity(0.8))
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .center)
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
    OnboardingCaregiverDetailsView(onConfirm: { details in
        print(details)
    }, onSkip: {})
}
