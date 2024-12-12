//
//  ContentView.swift
//  MAD9137_Final Assignment_Weather Application
//
//  Created by Terry Wong on 11/12/2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    var body: some View {
        CityListView()
    }
}
