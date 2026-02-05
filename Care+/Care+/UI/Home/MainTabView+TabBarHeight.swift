import SwiftUI

// This helper view modifier measures the height of any view and publishes it via TabBarHeightPreferenceKey
private struct MeasureHeight: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: TabBarHeightPreferenceKey.self, value: proxy.size.height)
                }
            )
    }
}

extension View {
    func measureTabBarHeight() -> some View { self.modifier(MeasureHeight()) }
}

// Wrapper to be used inside MainTabView where the BottomPillTabBar is overlaid.
// Usage inside MainTabView body (pseudocode):
// @State private var tabBarHeight: CGFloat = 0
// ZStack(alignment: .bottom) {
//   content
// }
// .overlay(
//   BottomPillTabBar(...)
//     .measureTabBarHeight()
// )
// .onPreferenceChange(TabBarHeightPreferenceKey.self) { h in self.tabBarHeight = h }
// .environment(\.tabBarHeight, tabBarHeight)
// Note: TabBarHeightPreferenceKey and tabBarHeight environment key are defined elsewhere.

struct MainTabView_TabBarHeightPlumbing: View {
    // This file is a lightweight reference and does not alter existing MainTabView behavior by itself.
    // Integrate the snippet above where your BottomPillTabBar is declared.
    var body: some View { EmptyView() }
}

