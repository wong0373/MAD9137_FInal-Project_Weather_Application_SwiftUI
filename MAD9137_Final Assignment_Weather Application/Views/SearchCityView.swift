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
    // Create few cities to show up for the view
    let popularCities = ["Tokyo", "New York", "Dubai", "London"]
    let allCities = ["Hong Kong", "Beijing", "Delhi", "Chennai", "Istanbul",
                     "Singapore", "Rome", "Mumbai", "Jakarta", "Tokyo", "Seoul"]

    // function to fetch the city name and add
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

    // For popular cities and all cities list, fetch the city name and add
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
                BackgroundView()
                    .ignoresSafeArea()

                VStack(spacing: 25) {
                    if !searchText.isEmpty {
                        searchResultsView
                    } else {
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
                                                    .scaleEffect(0.1)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(Color.white.opacity(0.2))
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

                        ScrollView {
                            VStack {
                                ForEach(allCities, id: \.self) { city in
                                    HStack {
                                        Text(city)
                                            .foregroundColor(.white)
                                            .fontWeight(.bold)
                                        Spacer()
                                        if selectedCity == city && isLoading {
                                            ProgressView()
                                                .scaleEffect(0.1)
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
                                        .frame(width: 370, height: 0.7)
                                        .background(Color.white)
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search for a city")
            .onChange(of: searchText) { _, newValue in
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
