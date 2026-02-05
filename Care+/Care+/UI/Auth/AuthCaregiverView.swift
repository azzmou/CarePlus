import SwiftUI

struct AuthCaregiverView: View {
    @Bindable var state: AppState

    @State private var name = ""
    @State private var surname = ""
    @State private var typeIndex = 0
    @State private var phone = ""
    @State private var email = ""

    @State private var goFinal = false

    private let types = ["Family", "Professional", "Friend"]

    init(state: AppState) {
        self._state = .init(state)
        if let saved = UserDefaults.standard.dictionary(forKey: "caregiver_pending_v1") as? [String: String] {
            _name = State(initialValue: saved["name"] ?? "")
            _surname = State(initialValue: saved["surname"] ?? "")
            if let savedType = saved["type"], let index = types.firstIndex(of: savedType) {
                _typeIndex = State(initialValue: index)
            }
            _phone = State(initialValue: saved["phone"] ?? "")
            _email = State(initialValue: saved["email"] ?? "")
        }
    }

    var body: some View {
        Screen {
            VStack(alignment: .leading, spacing: 16) {
                Text("Who is your caregiver?")
                    .font(.title.weight(.bold))
                    .foregroundStyle(AppTheme.textPrimary)

                VStack(spacing: 12) {
                    AuthTextField(title: "Name", text: $name)
                    AuthTextField(title: "Surname", text: $surname)
                    Picker("Tipology", selection: $typeIndex) {
                        ForEach(0..<types.count, id: \.self) { i in
                            Text(types[i]).tag(i)
                        }
                    }
                    .pickerStyle(.segmented)
                    AuthTextField(title: "Phone Number", text: $phone)
                        .keyboardType(.phonePad)
                    AuthTextField(title: "Email", text: $email)
                        .keyboardType(.emailAddress)
                }

                PrimaryPillButton("Confirm") {
                    saveCaregiverLocally()
                    goFinal = true
                }

                Button("Skip for now") { goFinal = true }
                    .tint(AppTheme.primary)

                NavigationLink(destination: AuthFinalWelcomeView(state: state), isActive: $goFinal) { EmptyView() }

                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle("")
        .toolbarTitleDisplayMode(.inline)
    }

    private func saveCaregiverLocally() {
        let dict: [String: String] = [
            "name": name,
            "surname": surname,
            "type": types[typeIndex],
            "phone": phone,
            "email": email
        ]
        UserDefaults.standard.set(dict, forKey: "caregiver_pending_v1")
    }
}
