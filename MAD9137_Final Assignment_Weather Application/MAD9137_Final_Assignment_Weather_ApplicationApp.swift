//
//  MAD9137_Final_Assignment_Weather_ApplicationApp.swift
//  MAD9137_Final Assignment_Weather Application
//
//  Created by Terry Wong on 10/12/2024.
//

import SwiftUI

@main
struct WeatherApp: App {
    @StateObject private var weatherViewModel = WeatherViewModel()

    var body: some Scene {
        WindowGroup {
            CityListView()
                .environmentObject(weatherViewModel)
        }
    }
}
