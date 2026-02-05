import SwiftUI

struct ContentView: View {
    @State private var searchText = ""
    @State private var state = AppState()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Search bar
                    TextField("Search", text: $searchText)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal)

                    CardDark {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Address Book")
                                .font(.title2)
                                .bold()

                            Button(action: {
                                // Import from contacts action
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.down")
                                    Text("Import from Contacts")
                                }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }

                            NavigationLink {
                                DialPadView(state: state)
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "circle.grid.3x3.fill")
                                    Text("Dial pad")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity, minHeight: 48)
                                .background(Color.white)
                                .foregroundStyle(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            .buttonStyle(.plain)

                            Text("You can import contacts to quickly add them or use the dial pad to enter numbers manually.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Phone App")
        }
    }
}

struct CardDark<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(16)
            .padding(.horizontal)
    }
}

struct DialPadView: View {
    @ObservedObject var state: AppState

    var body: some View {
        Text("Dial Pad")
    }
}

class AppState: ObservableObject {
    // State management
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
