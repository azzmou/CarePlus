import SwiftUI
import Combine

enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "System"
        case .light:  return "White mode"
        case .dark:   return "Dark mode"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

final class AppearanceSettings: ObservableObject {
    @Published var selected: AppAppearance {
        didSet { UserDefaults.standard.set(selected.rawValue, forKey: key) }
    }

    private let key = "selectedAppearance"

    init() {
        if let raw = UserDefaults.standard.string(forKey: key),
           let ap = AppAppearance(rawValue: raw) {
            selected = ap
        } else {
            selected = .system
        }
    }
}

