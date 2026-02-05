import SwiftUI

struct SignUpStep2CaregiverView: View {
    @Binding var caregiverFirstName: String
    @Binding var caregiverLastName: String
    @Binding var caregiverRelationship: String
    @Binding var caregiverPhone: String
    @Binding var caregiverEmail: String
    
    var isLoading: Bool
    var errorMessage: String?
    
    var onConfirm: () -> Void
    var onSkip: () -> Void
    
    private let relationships = ["Family", "Friend", "Doctor", "Other"]
    
    var isConfirmDisabled: Bool {
        caregiverFirstName.trimmingCharacters(in: .whitespaces).isEmpty ||
        (caregiverPhone.trimmingCharacters(in: .whitespaces).isEmpty && caregiverEmail.trimmingCharacters(in: .whitespaces).isEmpty)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Who is your caregiver? (optional)")
                .font(.title2).bold()
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.top, 32)
            
            VStack(spacing: 16) {
                TextField("First name", text: $caregiverFirstName)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
                
                TextField("Last name", text: $caregiverLastName)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
                
                Picker("Relationship", selection: $caregiverRelationship) {
                    ForEach(relationships, id: \.self) { relationship in
                        Text(relationship).tag(relationship)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                TextField("Phone number", text: $caregiverPhone)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.phonePad)
                    .disableAutocorrection(true)
                
                TextField("Email", text: $caregiverEmail)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: {
                    onConfirm()
                }) {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                            .progressViewStyle(.circular)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Confirm")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(isConfirmDisabled ? Color.gray.opacity(0.4) : Color.accentColor)
                .cornerRadius(12)
                .disabled(isConfirmDisabled || isLoading)
                
                Button(action: {
                    onSkip()
                }) {
                    Text("Skip for now")
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(12)
                .disabled(isLoading)
            }
            .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
    }
}
