//
//  WeatherService.swift
//  MAD9137_Final Assignment_Weather Application
//
//  Created by Terry Wong on 11/12/2024.
//

import Foundation

class WeatherService: ObservableObject {
    private let apiKey = "c080ccfd5187d10f8981d2b2641dc086"
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    
    @Published var cities: [City] = []
    
    func fetchWeather(for cityName: String) async throws -> WeatherResponse {
        let urlString = "\(baseURL)?q=\(cityName)&appid=\(apiKey)&units=metric"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            throw WeatherError.invalidURL
        }
                
        let (data, response) = try await URLSession.shared.data(from: url)
                
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            throw WeatherError.invalidResponse
        }
                
        let decoder = JSONDecoder()
        let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
        return weatherResponse
    }
}

enum WeatherError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
