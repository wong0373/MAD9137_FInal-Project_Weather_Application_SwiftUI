//
//  SettingsView.swift
//  MAD9137_Final Assignment_Weather Application
//
//  Created by Terry Wong on 12/12/2024.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @AppStorage("refreshInterval") private var refreshInterval: TimeInterval = 60.0 {
        didSet {
            viewModel.updateRefreshTimer(interval: refreshInterval)
        }
    }

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
                BackgroundView()
                    .ignoresSafeArea()
                List {
                    Picker("Refresh Interval", selection: $refreshInterval) {
                        ForEach(refreshIntervalOptions, id: \.1) { option in
                            Text(option.0).tag(option.1)
                        }
                    }

                    Section {
                        NavigationLink {
                            AboutView()
                        } label: {
                            Text("About")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(red: 0.4, green: 0.5, blue: 0.9), for: .navigationBar)
            .toolbarBackground(.visible)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onAppear {
            // Ensure timer is running with current interval when view appears
            viewModel.updateRefreshTimer(interval: refreshInterval)
        }
    }

    private struct BackgroundView: View {
        var body: some View {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 135/255, green: 206/255, blue: 235/255),
                    Color(red: 65/255, green: 105/255, blue: 225/255)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(WeatherViewModel())
    }
}
