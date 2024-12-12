//
//  SettingsView.swift
//  MAD9137_Final Assignment_Weather Application
//
//  Created by Terry Wong on 12/12/2024.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @AppStorage("refreshInterval") private var refreshInterval = 300.0 // default 5 minutes

    let refreshIntervalOptions: [(String, TimeInterval)] = [
        ("1 minute", 60),
        ("5 minutes", 300),
        ("15 minutes", 900),
        ("30 minutes", 1800),
        ("1 hour", 3600)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    Section("Auto Refresh") {
                        Picker("Refresh Interval", selection: $refreshInterval) {
                            ForEach(refreshIntervalOptions, id: \.1) { option in
                                Text(option.0).tag(option.1)
                            }
                        }
                        .onChange(of: refreshInterval) { newValue in
                            viewModel.updateRefreshTimer(interval: newValue)
                        }
                    }

                    Section {
                        NavigationLink {
                            AboutView()
                                .toolbar(.hidden, for: .tabBar)
                        } label: {
                            Text("About")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(WeatherViewModel())
    }
}
