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
    let coord: Coordinates
    let wind: Wind
}

struct Wind: Codable {
    let speed: Double
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

struct Coordinates: Codable {
    let lat: Double
    let lon: Double
}

struct WeatherDetail: Codable {
    let temperature: Double
    let feelsLike: Double
    let humidity: Int
    let pressure: Int
    let windSpeed: Double
    let description: String
    let icon: String
    let hourlyForecast: [HourlyWeatherData]

    init(temperature: Double, feelsLike: Double, humidity: Int, pressure: Int,
         windSpeed: Double, description: String, icon: String,
         hourlyForecast: [HourlyWeatherData])
    {
        self.temperature = temperature
        self.feelsLike = feelsLike
        self.humidity = humidity
        self.pressure = pressure
        self.windSpeed = windSpeed
        self.description = description
        self.icon = icon
        self.hourlyForecast = hourlyForecast
    }
    
    enum CodingKeys: String, CodingKey {
        case main
        case weather
        case wind
        case hourly
    }
    
    enum MainKeys: String, CodingKey {
        case temperature = "temp"
        case feelsLike = "feels_like"
        case humidity
        case pressure
    }
    
    enum WindKeys: String, CodingKey {
        case windSpeed = "speed"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let mainContainer = try container.nestedContainer(keyedBy: MainKeys.self, forKey: .main)
        temperature = try mainContainer.decode(Double.self, forKey: .temperature)
        feelsLike = try mainContainer.decode(Double.self, forKey: .feelsLike)
        humidity = try mainContainer.decode(Int.self, forKey: .humidity)
        pressure = try mainContainer.decode(Int.self, forKey: .pressure)
        
        let windContainer = try container.nestedContainer(keyedBy: WindKeys.self, forKey: .wind)
        windSpeed = try windContainer.decode(Double.self, forKey: .windSpeed)
        
        let weatherArray = try container.decode([Weather].self, forKey: .weather)
        guard let firstWeather = weatherArray.first else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Weather array is empty"
            ))
        }
        description = firstWeather.description
        icon = firstWeather.icon
        
        // Decode hourly forecast if available
        if let hourlyData = try? container.decode([HourlyForecastResponse].self, forKey: .hourly) {
            hourlyForecast = hourlyData.prefix(24).map { HourlyWeatherData(from: $0) }
        } else {
            hourlyForecast = []
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        var mainContainer = container.nestedContainer(keyedBy: MainKeys.self, forKey: .main)
        try mainContainer.encode(temperature, forKey: .temperature)
        try mainContainer.encode(feelsLike, forKey: .feelsLike)
        try mainContainer.encode(humidity, forKey: .humidity)
        try mainContainer.encode(pressure, forKey: .pressure)
        
        var windContainer = container.nestedContainer(keyedBy: WindKeys.self, forKey: .wind)
        try windContainer.encode(windSpeed, forKey: .windSpeed)
        
        try container.encode([Weather(description: description, icon: icon)], forKey: .weather)
        
        // Encode hourly forecast
        let hourlyResponses = hourlyForecast.map { hourly in
            HourlyForecastResponse(
                dt: Int(hourly.time.timeIntervalSince1970),
                temp: hourly.temperature,
                pop: hourly.precipitation,
                weather: [Weather(description: "", icon: hourly.icon)]
            )
        }
        try container.encode(hourlyResponses, forKey: .hourly)
    }
}

struct DetailedWeatherResponse: Codable {
    struct Current: Codable {
        let temp: Double
        let feels_like: Double
        let humidity: Int
        let pressure: Int
        let wind_speed: Double
        let weather: [Weather]
    }
    
    struct Hourly: Codable {
        let dt: Int
        let temp: Double
        let pop: Double?
        let weather: [Weather]
    }
    
    let current: Current
    let hourly: [Hourly]
}

struct HourlyForecastResponse: Codable {
    let dt: Int
    let temp: Double
    let pop: Double
    let weather: [Weather]
}

struct HourlyWeatherData: Codable {
    let time: Date
    let temperature: Double
    let icon: String
    let precipitation: Double
    
    init(from response: HourlyForecastResponse) {
        time = Date(timeIntervalSince1970: TimeInterval(response.dt))
        temperature = response.temp
        icon = response.weather.first?.icon ?? ""
        precipitation = response.pop
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let response = HourlyForecastResponse(
            dt: Int(time.timeIntervalSince1970),
            temp: temperature,
            pop: precipitation,
            weather: [Weather(description: "", icon: icon)]
        )
        try container.encode(response)
    }
}

struct City: Identifiable, Codable, Hashable {
    var id = UUID()
    let name: String
    let temperature: Double
    let weatherDescription: String
    let weatherIcon: String
    let localTime: Date
    let country: String
    let timeZone: String?
    let coordinates: Coordinates
    let humidity: Int
    let windSpeed: Double
    
    init(name: String, temperature: Double, weatherDescription: String, weatherIcon: String, localTime: Date, country: String, timeZone: String?, coordinates: Coordinates, humidity: Int, windSpeed: Double) {
        self.name = name
        self.temperature = temperature
        self.weatherDescription = weatherDescription
        self.weatherIcon = weatherIcon
        self.localTime = localTime
        self.country = country
        self.timeZone = timeZone
        self.coordinates = coordinates
        self.humidity = humidity
        self.windSpeed = windSpeed
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: City, rhs: City) -> Bool {
        lhs.id == rhs.id
    }
}
