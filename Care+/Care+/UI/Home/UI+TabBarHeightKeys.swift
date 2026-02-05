import SwiftUI

public struct TabBarHeightPreferenceKey: PreferenceKey {
    public static var defaultValue: CGFloat = 0
    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct TabBarHeightEnvironmentKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    var tabBarHeight: CGFloat {
        get { self[TabBarHeightEnvironmentKey.self] }
        set { self[TabBarHeightEnvironmentKey.self] = newValue }
    }
}
