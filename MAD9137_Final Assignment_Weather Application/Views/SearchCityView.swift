//
//  SearchCityView.swift
//  MAD9137_Final Assignment_Weather Application
//
//  Created by Terry Wong on 11/12/2024.
//

import SwiftUI

struct SearchCityView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var searchResults: [GeocodingResult] = []
    @State private var selectedCity: String? = nil

    let weatherService = WeatherService()
    let popularCities = ["Tokyo", "New York", "Dubai", "London"]
    let allCities = ["Hong Kong", "Beijing", "Delhi", "Chennai", "Istanbul",
                     "Singapore", "Rome", "Mumbai", "Jakarta", "Tokyo", "Seoul"]

    func fetchAndAddCity(_ result: GeocodingResult) {
        isLoading = true
        selectedCity = result.name
        Task {
            do {
                let weatherData = try await weatherService.fetchWeather(for: result.name)
                let city = City(
                    name: weatherData.name,
                    temperature: weatherData.main.temp,
                    weatherDescription: weatherData.weather.first?.description ?? "",
                    weatherIcon: weatherData.weather.first?.icon ?? "",
                    localTime: Date(),
                    country: weatherData.sys.country,
                    timeZone: nil,
                    coordinates: Coordinates(lat: result.lat, lon: result.lon),
                    humidity: weatherData.main.humidity,
                    windSpeed: weatherData.wind.speed
                )
                await MainActor.run {
                    weatherViewModel.addCity(city)
                    isLoading = false
                    selectedCity = nil
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    selectedCity = nil
                    alertMessage = "Could not fetch weather data for this city. Please try again."
                    showAlert = true
                }
            }
        }
    }

    // For popular cities and all cities list
    func fetchAndAddCityByName(_ cityName: String) {
        isLoading = true
        selectedCity = cityName
        Task {
            do {
                let weatherData = try await weatherService.fetchWeather(for: cityName)
                let city = City(
                    name: weatherData.name,
                    temperature: weatherData.main.temp,
                    weatherDescription: weatherData.weather.first?.description ?? "",
                    weatherIcon: weatherData.weather.first?.icon ?? "",
                    localTime: Date(),
                    country: weatherData.sys.country,
                    timeZone: nil,
                    coordinates: Coordinates(lat: weatherData.coord.lat, lon: weatherData.coord.lon),
                    humidity: weatherData.main.humidity,
                    windSpeed: weatherData.wind.speed
                )
                await MainActor.run {
                    weatherViewModel.addCity(city)
                    isLoading = false
                    selectedCity = nil
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    selectedCity = nil
                    alertMessage = "Could not find weather for this city. Please try again."
                    showAlert = true
                }
            }
        }
    }

    func performSearch(query: String) {
        Task {
            do {
                let results = try await weatherService.geocodeCity(query)
                await MainActor.run {
                    searchResults = results
                }
            } catch {
                await MainActor.run {
                    searchResults = []
                    alertMessage = "Error searching for cities"
                    showAlert = true
                }
            }
        }
    }

    var searchResultsView: some View {
        List(searchResults) { result in
            HStack {
                VStack(alignment: .leading) {
                    Text(result.name)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                    if let state = result.state {
                        Text(state)
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                }

                Spacer()

                Text(result.country)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
            }
            .listRowBackground(Color.clear)
            .onTapGesture {
                fetchAndAddCity(result)
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(PlainListStyle())
        .background(Color.clear)
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Your existing gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 135/255, green: 206/255, blue: 235/255),
                        Color(red: 35/255, green: 35/255, blue: 25/255)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    if !searchText.isEmpty {
                        searchResultsView
                    } else {
                        // Your existing popular cities section
                        VStack(alignment: .leading) {
                            Text("Popular Cities")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .padding(.leading)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(popularCities, id: \.self) { city in
                                        HStack {
                                            Text(city)
                                                .fontWeight(.bold)
                                            if selectedCity == city && isLoading {
                                                ProgressView()
                                                    .scaleEffect(0.8)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(20)
                                        .foregroundColor(.white)
                                        .onTapGesture {
                                            fetchAndAddCityByName(city)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        // Your existing all cities list
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(allCities, id: \.self) { city in
                                    HStack {
                                        Text(city)
                                            .foregroundColor(.white)
                                            .fontWeight(.bold)
                                        Spacer()
                                        if selectedCity == city && isLoading {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                        } else {
                                            Image(systemName: "plus")
                                                .foregroundColor(.white)
                                                .fontWeight(.bold)
                                        }
                                    }
                                    .padding()
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        fetchAndAddCityByName(city)
                                    }
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search for a city...")
            .onChange(of: searchText) { newValue in
                if newValue.count >= 3 {
                    performSearch(query: newValue)
                } else {
                    searchResults = []
                }
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Search for City")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

#Preview {
    SearchCityView()
        .environmentObject(WeatherViewModel())
}
