import SwiftUI

// DEPRECATED: Prefer RolePickerView. Do not use in production flow.

struct RoleSelectionCompactView: View {
    @Binding var selectedRole: String
    let roles: [String]

    var body: some View {
        VStack {
            Text("Select your role")
                .font(.headline)
            Picker("Role", selection: $selectedRole) {
                ForEach(roles, id: \.self) { role in
                    Text(role).tag(role)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding()
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedRole = "User (Patient)"
        var body: some View {
            RoleSelectionCompactView(
                selectedRole: $selectedRole,
                roles: ["User (Patient)", "Caregiver"]
            )
        }
    }
    return PreviewWrapper()
}
