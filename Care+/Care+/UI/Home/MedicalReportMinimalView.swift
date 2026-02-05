import SwiftUI

struct MedicalReportView: View {
    @Bindable var state: AppState
    
    var body: some View {
        VStack {
            Button("Add medical report") {
                // Action to add medical report
            }
            Text("Medical report status")
        }
        .padding()
    }
}

struct MedicalReportView_Previews: PreviewProvider {
    static var previews: some View {
        MedicalReportView(state: AppState())
    }
}
