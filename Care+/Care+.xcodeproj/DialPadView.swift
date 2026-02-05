import SwiftUI
import UIKit

struct DialPadView: View {
    @Bindable var state: AppState
    @State private var input: String = ""

    private var digitsOnly: String { input.filter(\.isNumber) }

    private var matchedContact: ContactItem? {
        let d = digitsOnly
        guard !d.isEmpty else { return nil }
        return state.contacts.first(where: { c in
            if let p = c.phone { return CallHelper.normalizedDigits(p).hasSuffix(d) } else { return false }
        })
    }

    var body: some View {
        NavigationStack {
            Screen {
                CardDark {
                    HStack(spacing: 10) {
                        Image(systemName: "phone.fill").foregroundStyle(.white)
                        Text("Dial").font(.headline.weight(.semibold)).foregroundStyle(.white)
                        Spacer()
                    }

                    Text(input.isEmpty ? "Enter number" : input)
                        .font(.title2.monospacedDigit().weight(.bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                        .accessibilityLabel(input)

                    if let m = matchedContact {
                        HStack {
                            Avatar(photo: m.photoData).frame(width: 36, height: 36)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(m.name).foregroundStyle(.white)
                                if let r = m.relation, !r.isEmpty { Text(r).font(.caption).foregroundStyle(.white.opacity(0.7)) }
                            }
                            Spacer()
                            Text(m.phone ?? "").font(.caption).foregroundStyle(.white.opacity(0.7))
                        }
                        .padding(10)
                        .background(Color.white.opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }

                dialGrid

                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    CallHelper.dial(raw: input, state: state)
                } label: {
                    Text("Call")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(input.isEmpty ? Color.white.opacity(0.35) : Color.white)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .disabled(input.isEmpty)
                .buttonStyle(.plain)
            }
            .navigationTitle("Dial")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var dialGrid: some View {
        VStack(spacing: 12) {
            ForEach([["1","2","3"],["4","5","6"],["7","8","9"],["*","0","#"]], id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { key in
                        Button {
                            tap(key)
                        } label: {
                            Text(key)
                                .font(.title.weight(.bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, minHeight: 60)
                                .background(Color.white.opacity(0.10))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            HStack(spacing: 12) {
                Button {
                    if !input.isEmpty { input.removeLast() }
                } label: {
                    Image(systemName: "delete.left")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(Color.white.opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.12), lineWidth: 1))
                }
                .buttonStyle(.plain)

                Button {
                    input = ""
                } label: {
                    Image(systemName: "xmark.circle")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 52)
                        .background(Color.white.opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.12), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 16)
    }

    private func tap(_ key: String) {
        input.append(contentsOf: key)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

#Preview {
    DialPadView(state: AppState())
}
