import SwiftUI
import UIKit

struct DialPadView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var state: AppState

    @State private var input: String = ""
    private let emergencyShortcuts: [(number: String, label: String)] = [("112","Emergenze"), ("118","Ambulanza"), ("115","Vigili del Fuoco")]

    private let rows: [[String]] = [["1","2","3"],["4","5","6"],["7","8","9"],["*","0","#"]]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [AppTheme.gradientTop, AppTheme.gradientBottom],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 18) {
                    // Display
                    Text(formattedInput)
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(.white)
                        .overlay(alignment: .trailing) {
                            HStack(spacing: 10) {
                                if !input.isEmpty {
                                    Button {
                                        if !input.isEmpty { _ = input.removeLast() }
                                    } label: {
                                        Image(systemName: "delete.left.fill")
                                            .font(.title2)
                                            .foregroundStyle(.white)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.trailing, 16)
                        }

                    // Emergency shortcuts
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(emergencyShortcuts, id: \.number) { item in
                                Button {
                                    input = item.number
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "phone.fill")
                                        Text(item.number)
                                    }
                                    .font(.subheadline.weight(.semibold))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color.white)
                                    .foregroundStyle(.black)
                                    .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }

#if targetEnvironment(simulator)
                    Text("⚠️ Le chiamate non funzionano nel Simulator. Prova su un iPhone reale.")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.8))
#endif

                    Spacer(minLength: 0)

                    // Keypad
                    VStack(spacing: 12) {
                        ForEach(0..<rows.count, id: \.self) { r in
                            HStack(spacing: 12) {
                                ForEach(rows[r], id: \.self) { key in
                                    Button { tap(key) } label: {
                                        VStack(spacing: 2) {
                                            Text(key)
                                                .font(.system(size: 28, weight: .semibold))
                                        }
                                        .frame(width: 86, height: 64)
                                        .background(Color.white.opacity(0.12))
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    // Call + Clear
                    HStack(spacing: 12) {
                        Button {
                            input.removeAll()
                        } label: {
                            Text("Clear")
                                .font(.headline)
                                .frame(maxWidth: .infinity, minHeight: 52)
                                .background(Color.white.opacity(0.14))
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.18), lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .disabled(input.isEmpty)

                        Button {
                            call()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "phone.fill")
                                Text("Chiama")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(input.isEmpty ? Color.white.opacity(0.35) : Color.white)
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .disabled(input.isEmpty)
                    }
                    .padding(.top, 6)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Chiudi") { dismiss() }
                }
            }
            .navigationTitle("Componi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var formattedInput: String {
        guard !input.isEmpty else { return "" }
        let digits = input
        // Simple grouping for readability
        var out = ""
        for (i, ch) in digits.enumerated() {
            if i > 0 && i % 3 == 0 { out.append(" ") }
            out.append(ch)
        }
        return out
    }

    private func tap(_ key: String) {
        input.append(contentsOf: key)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func call() {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        CallHelper.dial(raw: trimmed, state: state)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dismiss()
    }
}

#Preview {
    struct Wrapper: View {
        @State var state = AppState()
        var body: some View { DialPadView(state: state) }
    }
    return Wrapper()
}

