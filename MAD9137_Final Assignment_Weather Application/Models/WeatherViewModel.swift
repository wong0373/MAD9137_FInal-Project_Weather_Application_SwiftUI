//
//  WeatherViewModel.swift
//  MAD9137_Final Assignment_Weather Application
//
//  Created by Terry Wong on 11/12/2024.
//

import Foundation

@MainActor
class WeatherViewModel: ObservableObject {
    @Published var cities: [City] = []
    private let weatherService = WeatherService()

    // List of cities you want to display
    private let cityNames = ["Ottawa", "Tokyo", "Montreal", "Vancouver", "Calgary"]

    func fetchAllCityWeather() {
        Task {
            for cityName in cityNames {
                do {
                    let response = try await weatherService.fetchWeather(for: cityName)
                    let city = City(
                        name: response.name,
                        temperature: response.main.temp,
                        weatherDescription: response.weather.first?.description ?? "",
                        weatherIcon: response.weather.first?.icon ?? "",
                        localTime: Date(timeIntervalSince1970: Double(response.dt))
                    )
                    cities.append(city)
                } catch {
                    print("Error fetching weather for \(cityName): \(error)")
                }
            }
        }
    }
}
