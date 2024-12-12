//
//  WeatherModel.swift
//  MAD9137_Final Assignment_Weather Application
//
//  Created by Terry Wong on 11/12/2024.
//

import Foundation

struct WeatherResponse: Codable {
    let main: MainWeather
    let weather: [Weather]
    let name: String
    let dt: Int
}

struct MainWeather: Codable {
    let temp: Double
}

struct Weather: Codable {
    let description: String
    let icon: String
}

struct City: Identifiable {
    let id = UUID()
    let name: String
    var temperature: Double
    var weatherDescription: String
    var weatherIcon: String
    var localTime: Date
}
