import SwiftUI

struct CardDark<Content: View>: View {
    @Environment(\.colorScheme) private var scheme

    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 20, style: .continuous)

        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding()
        .background(
            shape
                // superficie principale
                .fill(AppTheme.surface)
                // leggero lift neutro (profondità)
                .overlay(
                    shape.fill(
                        scheme == .dark
                        ? Color.white.opacity(0.03)
                        : Color.black.opacity(0.02)
                    )
                )
        )
        .clipShape(shape)
        .overlay(
            shape.stroke(
                scheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.08),
                lineWidth: 1
            )
        )
        .shadow(
            color: scheme == .dark ? .black.opacity(0.22) : .black.opacity(0.08),
            radius: scheme == .dark ? 14 : 10,
            x: 0,
            y: scheme == .dark ? 7 : 5
        )
    }
}
