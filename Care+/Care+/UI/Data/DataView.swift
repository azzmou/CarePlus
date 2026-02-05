//
//  DataView.swift
//  Care+
//

import SwiftUI

struct DataView: View {
    @Bindable var state: AppState
    @State private var selection: DataSection = .games

    enum DataSection: String, CaseIterable {
        case games = "Games"
        // case calls = "Calls"  // removed because CallsStatsView was removed
    }

    var body: some View {
        NavigationStack {
            Screen {
                CardDark {
                    Text("Data")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)

                    Picker("Section", selection: $selection) {
                        ForEach(DataSection.allCases, id: \.self) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                switch selection {
                case .games:
                    GamesStatsView(state: state)
                }
            }
            .navigationTitle("Data")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}
