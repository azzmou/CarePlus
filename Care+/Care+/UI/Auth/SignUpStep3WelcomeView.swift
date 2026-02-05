import SwiftUI

struct SignUpStep3WelcomeView: View {
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image(systemName: "brain.head.profile")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundStyle(Color.accentColor)
            
            VStack(spacing: 8) {
                Text("Welcome!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text("You're all set.")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button(action: onStart) {
                Text("Start")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground)).ignoresSafeArea()
    }
}

struct SignUpStep3WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpStep3WelcomeView {
            // Preview action
        }
    }
}
