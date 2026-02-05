import SwiftUI

struct AddContactSheet: View {
    var onAdd: (CareContact) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var step: Int = 1
    @State private var type: CareContactType = .family
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var role: String = ""
    @State private var phone: String = ""
    @State private var image: UIImage? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: 0x2A0D4A).ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        if step == 1 { formStep } else { keypadStep }
                    }
                    .padding(16)
                }
            }
            .navigationTitle(step == 1 ? "Add a new contact" : "")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "person.2.fill")
                        .foregroundStyle(.white.opacity(0.9))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
            }
        }
    }

    private var formStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Picker("Tipology", selection: $type) {
                ForEach(CareContactType.allCases) { t in
                    Text(t.rawValue).tag(t)
                }
            }
            .pickerStyle(.menu)
            .tint(.white)

            Group {
                TextField("Name", text: $firstName)
                TextField("Surname", text: $lastName)
                TextField("Role (e.g. Daughter)", text: $role)
            }
            .textFieldStyle(.roundedBorder)
            .tint(.white)

            VStack(alignment: .leading, spacing: 8) {
                Text("Add a photo")
                    .foregroundStyle(.white.opacity(0.9))
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 140)
                    Image(systemName: "plus")
                        .foregroundStyle(.white.opacity(0.8))
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Record voice")
                    .foregroundStyle(.white.opacity(0.9))
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 80)
                    Image(systemName: "mic.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.white.opacity(0.9))
                }
            }

            Spacer()

            Button {
                step = 2
            } label: {
                Text("Next")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color.white)
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .foregroundStyle(.white)
    }

    private var keypadStep: some View {
        VStack(spacing: 16) {
            Image(systemName: "mic.fill")
                .foregroundStyle(.white.opacity(0.9))
                .padding(.top, 8)

            Text(phoneSpacedFormatted)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.bottom, 8)

            KeypadView(text: $phone)

            HStack(spacing: 12) {
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.white.opacity(0.18))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.2), lineWidth: 1))
                }
                Button {
                    let contact = CareContact(type: type, firstName: firstName, lastName: lastName, roleDescription: role, phoneNumber: phone, imageName: nil)
                    onAdd(contact)
                    dismiss()
                } label: {
                    Text("Confirm")
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.white)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .disabled(phone.isEmpty)
            }
            .padding(.top, 8)
        }
    }

    private var phoneSpacedFormatted: String {
        let digits = phone.filter { $0.isNumber }
        // Format as (XXX) XXX-XXXX or similar
        var result = ""
        let chars = Array(digits)
        for (i, ch) in chars.enumerated() {
            if i == 0 { result.append("(") }
            if i == 3 { result.append(") ") }
            if i == 6 { result.append("-") }
            if i < 10 {
                result.append(ch)
            }
        }
        return result
    }
}

private struct KeypadView: View {
    @Binding var text: String

    private let rows: [[String]] = [["1","2","3"],["4","5","6"],["7","8","9"],["*","0","#"]]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<rows.count, id: \.self) { r in
                HStack(spacing: 12) {
                    ForEach(rows[r], id: \.self) { key in
                        Button { tap(key) } label: {
                            Text(key)
                                .font(.title2.weight(.semibold))
                                .frame(width: 80, height: 80)
                                .background(Color.white.opacity(0.12))
                                .foregroundStyle(.white)
                                .clipShape(Circle())
                        }
                    }
                }
            }
        }
    }

    private func tap(_ key: String) {
        if key == "#" {
            if !text.isEmpty { _ = text.removeLast() }
            return
        }
        text.append(contentsOf: key)
    }
}

private extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

// Dummy definitions to allow compiling, replace or remove as needed in real project:
struct CareContact: Identifiable {
    let id = UUID()
    var type: CareContactType
    var firstName: String
    var lastName: String
    var roleDescription: String
    var phoneNumber: String
    var imageName: String?
}

enum CareContactType: String, CaseIterable, Identifiable {
    case family = "Family"
    case friend = "Friend"
    case colleague = "Colleague"
    case other = "Other"
    var id: String { rawValue }
}
