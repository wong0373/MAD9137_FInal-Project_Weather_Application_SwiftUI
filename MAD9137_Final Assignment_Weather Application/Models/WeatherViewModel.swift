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
    @Published var isLoading = false
    @Published var error: Error?
    @Published var hourlyForecast: [HourlyWeatherData] = []
    
    private let weatherService = WeatherService()
    private let userDefaultsKey = "savedCities"

    init() {
        loadCities()
        // Fetch weather data for initial cities
        fetchAllCityWeather()
    }
    
    private func loadCities() {
        if let savedCities = UserDefaults.standard.data(forKey: userDefaultsKey) {
            if let decodedCities = try? JSONDecoder().decode([City].self, from: savedCities) {
                cities = decodedCities
                return
            }
        }
        
        // Set default cities if no saved data
        cities = [
            City(name: "Ottawa", temperature: 0, weatherDescription: "", weatherIcon: "", localTime: Date(), country: String(), timeZone: String(), coordinates: Coordinates(lat: 0, lon: 0), humidity: 0, windSpeed: 0),
            City(name: "Tokyo", temperature: 0, weatherDescription: "", weatherIcon: "", localTime: Date(), country: String(), timeZone: String(), coordinates: Coordinates(lat: 0, lon: 0), humidity: 0, windSpeed: 0),
            City(name: "New York", temperature: 0, weatherDescription: "", weatherIcon: "", localTime: Date(), country: String(), timeZone: String(), coordinates: Coordinates(lat: 0, lon: 0), humidity: 0, windSpeed: 0),
            City(name: "London", temperature: 0, weatherDescription: "", weatherIcon: "", localTime: Date(), country: String(), timeZone: String(), coordinates: Coordinates(lat: 0, lon: 0), humidity: 0, windSpeed: 0),
            City(name: "Sydney", temperature: 0, weatherDescription: "", weatherIcon: "", localTime: Date(), country: String(), timeZone: String(), coordinates: Coordinates(lat: 0, lon: 0), humidity: 0, windSpeed: 0)
        ]
        saveCities()
    }
    
    private func saveCities() {
        if let encoded = try? JSONEncoder().encode(cities) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func deleteCity(_ city: City) {
        if let index = cities.firstIndex(where: { $0.id == city.id }) {
            cities.remove(at: index)
            saveCities()
        }
    }
    
    func addCity(_ city: City) {
        cities.insert(city, at: 0)
        saveCities()
        // Fetch weather for the newly added city
        fetchAllCityWeather()
    }
    
    func fetchAllCityWeather() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            var updatedCities: [City] = []
            for cityName in cities.map({ $0.name }) {
                do {
                    let weatherResponse = try await weatherService.fetchWeather(for: cityName) // Changed from response to weatherResponse
                    let city = City(
                        name: weatherResponse.name,
                        temperature: weatherResponse.main.temp,
                        weatherDescription: weatherResponse.weather.first?.description ?? "",
                        weatherIcon: weatherResponse.weather.first?.icon ?? "",
                        localTime: Date(timeIntervalSince1970: Double(weatherResponse.dt)),
                        country: weatherResponse.sys.country,
                        timeZone: weatherResponse.timezone.map { String($0) },
                        coordinates: Coordinates(lat: weatherResponse.coord.lat, lon: weatherResponse.coord.lon),
                        humidity: weatherResponse.main.humidity,
                        windSpeed: weatherResponse.wind.speed
                    )
                    updatedCities.append(city)
                } catch {
                    self.error = error
                    print("Error fetching weather for \(cityName): \(error)")
                }
            }
            
            if !updatedCities.isEmpty {
                self.cities = updatedCities
                saveCities()
            }
        }
    }

    func fetchForecast(for city: City) async {
        isLoading = true
        do {
            let forecast = try await weatherService.fetchForecast(
                lat: city.coordinates.lat,
                lon: city.coordinates.lon
            )
            await MainActor.run {
                self.hourlyForecast = forecast
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
            print("Error fetching forecast: \(error)")
        }
    }
}
