//
//  MainTabView.swift
//  MAD9137_Final Assignment_Weather Application
//
//  Created by Terry Wong on 12/12/2024.
//

import SwiftUI

struct MainTabView: View {
    init() {
        // Make tab bar transparent
        UITabBar.appearance().backgroundColor = .black.withAlphaComponent(0.8)
        UITabBar.appearance().barTintColor = .clear
//        UITabBar.appearance().isTranslucent = true
    }

    @EnvironmentObject var weatherViewModel: WeatherViewModel

    var body: some View {
        TabView {
            CityListView()
                .tabItem {
                    Image(systemName: "building.2")
                    Text("Cities")
                }

            SettingsView()
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
            .environmentObject(WeatherViewModel())
    }
}
