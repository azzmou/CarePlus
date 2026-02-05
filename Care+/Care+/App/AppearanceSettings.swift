import SwiftUI
import Combine

// Defines the app-wide appearance options and persists the user choice.
enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light mode"
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
    @AppStorage("appearance_mode") private var storedMode: String = "system"

    @Published var selected: AppAppearance = .system {
        didSet { storedMode = selected.rawValue }
    }

    init() {
        // After self is initialized with default selected, sync from storedMode
        let initial = AppAppearance(rawValue: storedMode) ?? .system
        self.selected = initial
    }
}

