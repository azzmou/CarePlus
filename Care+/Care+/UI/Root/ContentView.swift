//
//  ContentView.swift
//  Care+
//
//  Legacy wrapper (optional)
//  Root is RootView() in Care_App.swift
//

import SwiftUI

struct ContentView: View {
    @State private var state = AppState()
    @StateObject private var appearance = AppearanceSettings()

    var body: some View {
        RootView(state: state)
            .preferredColorScheme(appearance.selected.colorScheme)
            .environmentObject(appearance)
    }
}

#Preview {
    ContentView()
}
