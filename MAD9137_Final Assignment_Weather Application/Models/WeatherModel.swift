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
    let sys: Sys
    let timezone: Int?
}

struct Sys: Codable {
    let country: String
}

struct MainWeather: Codable {
    let temp: Double
    let humidity: Int
}

struct Weather: Codable {
    let description: String
    let icon: String
}

struct City: Identifiable, Codable {
    var id = UUID()
    let name: String
    let temperature: Double
    let weatherDescription: String
    let weatherIcon: String
    let localTime: Date
    let country: String
    let timeZone: String?

    init(name: String, temperature: Double, weatherDescription: String, weatherIcon: String, localTime: Date, country: String, timeZone: String?) {
        self.name = name
        self.temperature = temperature
        self.weatherDescription = weatherDescription
        self.weatherIcon = weatherIcon
        self.localTime = localTime
        self.country = country
        self.timeZone = timeZone
    }
}
