//
//  WeatherService.swift
//  MAD9137_Final Assignment_Weather Application
//
//  Created by Terry Wong on 11/12/2024.
//

import Foundation

class WeatherService: ObservableObject {
    private let apiKey = "bd5e378503939ddaee76f12ad7a97608"
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
    
    func fetchDetailedWeather(for city: City) async throws -> (WeatherDetail, [HourlyWeatherData]) {
        let urlString = "\(baseURL)?lat=\(city.coordinates.lat)&lon=\(city.coordinates.lon)&exclude=minutely,daily,alerts&appid=\(apiKey)&units=metric"
               
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }
               
        let (data, response) = try await URLSession.shared.data(from: url)
               
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            throw WeatherError.invalidResponse
        }
               
        let decoder = JSONDecoder()
        let detailResponse = try decoder.decode(DetailedWeatherResponse.self, from: data)
               
        // Get hourly forecasts
        let hourlyForecasts = detailResponse.hourly.prefix(5).map { hourly in
            HourlyWeatherData(from: HourlyForecastResponse(
                dt: hourly.dt,
                temp: hourly.temp,
                pop: hourly.pop ?? 0,
                weather: hourly.weather
            ))
        }
               
        let weatherDetail = WeatherDetail(
            temperature: detailResponse.current.temp,
            feelsLike: detailResponse.current.feels_like,
            humidity: detailResponse.current.humidity,
            pressure: detailResponse.current.pressure,
            windSpeed: detailResponse.current.wind_speed,
            description: detailResponse.current.weather.first?.description ?? "",
            icon: detailResponse.current.weather.first?.icon ?? "",
            hourlyForecast: hourlyForecasts
        )
            
        return (weatherDetail, Array(hourlyForecasts))
    }
        
    private func formatHour(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
        
private func formatHour(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
}

enum WeatherError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

struct CurrentWeather: Codable {
    let temp: Double
    let feels_like: Double
    let pressure: Int
    let humidity: Int
    let uvi: Double?
    let visibility: Int
    let wind_speed: Double
    let weather: [Weather]
}

struct HourlyWeather: Codable {
    let dt: Int
    let temp: Double
    let weather: [Weather]
    let pop: Double?
}
