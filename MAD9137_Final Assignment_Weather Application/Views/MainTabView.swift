//
//  MainTabView.swift
//  MAD9137_Final Assignment_Weather Application
//
//  Created by Terry Wong on 12/12/2024.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var weatherViewModel = WeatherViewModel()

    init() {
        // Make tab bar transparent
        UITabBar.appearance().backgroundColor = .black.withAlphaComponent(0.8)
        UITabBar.appearance().barTintColor = .clear
    }

    var body: some View {
        TabView {
            CityListView()
                .environmentObject(weatherViewModel)
                .tabItem {
                    Image(systemName: "building.2")
                    Text("Cities")
                }

            SettingsView()
                .environmentObject(weatherViewModel)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
