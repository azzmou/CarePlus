#if false
import SwiftUI

struct RoleSelectionView: View {
    @Bindable var state: AppState

    var body: some View {
        VStack(spacing: 24) {
            Text("Select Your Role")
                .font(.largeTitle)
                .bold()

            VStack(spacing: 12) {
                Button {
                    selectRole("user")
                } label: {
                    Text("User (Patient)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor.opacity(0.1))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    selectRole("caregiver")
                } label: {
                    Text("Caregiver")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor.opacity(0.1))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            Text("You will choose a role after each login.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("Role")
    }

    private func selectRole(_ role: String) {
        switch role.lowercased() {
        case "user", "patient":
            state.selectedRole = .user
        case "caregiver":
            state.selectedRole = .caregiver
        default:
            break
        }
    }
}

#Preview {
    NavigationStack {
        RoleSelectionView(state: AppState())
    }
}
#endif
