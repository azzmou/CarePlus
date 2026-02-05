import SwiftUI

struct AppearanceView: View {
    @AppStorage("appearance_mode") private var appearanceMode: String = "system"
    @Bindable var state: AppState

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $appearanceMode) {
                        Text("Follow System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(.inline)
                }
            }
            .navigationTitle("Appearance Settings")
        }
    }
}

struct AppearanceView_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceView(state: AppState())
    }
}
