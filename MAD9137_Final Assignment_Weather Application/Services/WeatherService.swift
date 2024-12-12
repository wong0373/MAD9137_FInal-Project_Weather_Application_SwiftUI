//
//  WeatherService.swift
//  MAD9137_Final Assignment_Weather Application
//
//  Created by Terry Wong on 11/12/2024.
//

import Foundation

class WeatherService: ObservableObject {
    private let apiKey = "7952697f77e6f0cb825f70e56819523d"
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
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(city.coordinates.lat)&lon=\(city.coordinates.lon)&units=metric&appid=\(apiKey)"
               
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
    
    func fetchForecast(lat: Double, lon: Double) async throws -> [HourlyWeatherData] {
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&units=metric&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200
        else {
            throw WeatherError.invalidResponse
        }
        
        struct ForecastResponse: Codable {
            struct ForecastItem: Codable {
                let dt: Int
                let main: MainWeather
                let weather: [Weather]
                let pop: Double
            }
            
            let list: [ForecastItem]
        }
        
        let decoder = JSONDecoder()
        let forecastResponse = try decoder.decode(ForecastResponse.self, from: data)
        
        return forecastResponse.list.prefix(8).map { item in // Changed to 8 for 24-hour forecast (3-hour intervals)
            HourlyWeatherData(
                time: Date(timeIntervalSince1970: TimeInterval(item.dt)),
                temperature: item.main.temp,
                icon: item.weather.first?.icon ?? "",
                precipitation: item.pop * 100
            )
        }
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

struct HourlyWeather: Codable, Identifiable {
    let dt: Int
    let temp: Double
    let weather: [Weather]
    let pop: Double?
    var id: Int { dt }
}
