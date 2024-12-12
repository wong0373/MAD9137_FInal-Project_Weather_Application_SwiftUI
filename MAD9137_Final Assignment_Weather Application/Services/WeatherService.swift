//
//  WeatherService.swift
//  MAD9137_Final Assignment_Weather Application
//
//  Created by Terry Wong on 11/12/2024.
//

import Foundation

class WeatherService {
    private let apiKey = "c080ccfd5187d10f8981d2b2641dc086"

    func fetchWeather(for city: String) async throws -> WeatherResponse {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let weather = try JSONDecoder().decode(WeatherResponse.self, from: data)
        return weather
    }
}
