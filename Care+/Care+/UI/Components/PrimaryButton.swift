//
//  PrimaryButton.swift
//  Care+
//

import SwiftUI

struct PrimaryButton: View {
    enum Style { case filled, soft }

    let title: String
    let style: Style
    let color: Color
    let isEnabled: Bool
    let action: () -> Void

    init(
        _ title: String,
        style: Style = .soft,
        color: Color = AppTheme.primary,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.color = color
        self.isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 56)
                .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(SoftButtonStyle(style: style, color: color))
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.45)
    }
}

private struct SoftButtonStyle: ButtonStyle {
    let style: PrimaryButton.Style
    let color: Color
    @Environment(\.colorScheme) private var scheme

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: 18, style: .continuous)

        // Testo: in filled vogliamo contrasto alto (su teal/giallo meglio scuro).
        // In soft (trasparente) meglio testo primario.
        let filledText: Color = (scheme == .dark) ? Color.black.opacity(0.85) : Color.white
        let softText: Color = AppTheme.textPrimary

        switch style {
        case .filled:
            configuration.label
                .background(
                    shape
                        .fill(color.opacity(configuration.isPressed ? 0.86 : 1.0))
                )
                .foregroundStyle(filledText)
                .clipShape(shape)
                .scaleEffect(configuration.isPressed ? 0.98 : 1)
                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: configuration.isPressed)
                .shadow(
                    color: .black.opacity(configuration.isPressed ? 0.16 : 0.22),
                    radius: configuration.isPressed ? 6 : 12,
                    x: 0,
                    y: configuration.isPressed ? 4 : 10
                )

        case .soft:
            configuration.label
                .background(
                    shape
                        .fill(
                            // “soft” = colore attenuato, non bianco fisso
                            color.opacity(scheme == .dark ? 0.18 : 0.12)
                        )
                )
                .foregroundStyle(softText)
                .clipShape(shape)
                .overlay(
                    shape.stroke(
                        // bordo soft coerente
                        color.opacity(scheme == .dark ? 0.28 : 0.22),
                        lineWidth: 1
                    )
                )
                .scaleEffect(configuration.isPressed ? 0.98 : 1)
                .animation(.spring(response: 0.25, dampingFraction: 0.85), value: configuration.isPressed)
                .shadow(
                    color: .black.opacity(configuration.isPressed ? 0.12 : 0.16),
                    radius: configuration.isPressed ? 4 : 10,
                    x: 0,
                    y: configuration.isPressed ? 3 : 8
                )
        }
    }
}
