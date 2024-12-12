//
//  SettingsView.swift
//  MAD9137_Final Assignment_Weather Application
//
//  Created by Terry Wong on 12/12/2024.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("General")) {
                    NavigationLink(destination: Text("About")) {
                        Label("About", systemImage: "info.circle")
                    }

                    NavigationLink(destination: Text("Help")) {
                        Label("Help", systemImage: "questionmark.circle")
                    }
                }

                Section(header: Text("Preferences")) {
                    NavigationLink(destination: Text("Temperature Unit")) {
                        Label("Temperature Unit", systemImage: "thermometer")
                    }

                    NavigationLink(destination: Text("Notifications")) {
                        Label("Notifications", systemImage: "bell")
                    }
                }

                Section(header: Text("App Info")) {
                    HStack {
                        Label("Version", systemImage: "apps.iphone")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(WeatherViewModel())
    }
}
