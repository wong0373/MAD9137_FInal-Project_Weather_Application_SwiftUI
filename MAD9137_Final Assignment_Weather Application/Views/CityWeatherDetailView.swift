import MapKit
import SwiftUI

struct CityWeatherDetailView: View {
    let latitude: Double
    let longitude: Double
    let cityName: String
    let weatherData: WeatherData
    
    private let gradient = LinearGradient(
        colors: [Color(red: 0.4, green: 0.5, blue: 0.9), Color(red: 0.2, green: 0.3, blue: 0.7)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: - Header Section

                headerSection
                
                // MARK: - Current Weather Section

                currentWeatherSection
                
                // MARK: - Hourly Forecast Section

                hourlyForecastSection
                
                // MARK: - Weather Details Grid

                weatherDetailsGrid
            }
            .padding()
        }
        .background(gradient)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 5) {
            Text(cityName)
                .font(.title)
                .bold()
                .foregroundColor(.white)
            
            Text(weatherData.description.capitalized)
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    // MARK: - Current Weather Section

    private var currentWeatherSection: some View {
        VStack(spacing: 10) {
            Text("\(Int(round(weatherData.temperature)))°")
                .font(.system(size: 80, weight: .thin))
                .foregroundColor(.white)
            
            Text("Feels like \(Int(round(weatherData.feelsLike)))°")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    // MARK: - Hourly Forecast Section

    private var hourlyForecastSection: some View {
        VStack(alignment: .leading) {
            Text("Hourly Forecast")
                .font(.title3)
                .bold()
                .foregroundColor(.white)
                .padding(.leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(weatherData.hourlyForecast, id: \.hour) { forecast in
                        VStack(spacing: 8) {
                            Text(forecast.hour)
                                .font(.caption)
                                .foregroundColor(.white)
                            
                            Image(systemName: forecast.icon)
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            Text("\(Int(round(forecast.temperature)))°")
                                .font(.title3)
                                .foregroundColor(.white)
                            
                            if forecast.precipitation > 0 {
                                Text("\(forecast.precipitation)%")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color.white.opacity(0.1))
            .cornerRadius(15)
        }
    }
    
    // MARK: - Weather Details Grid

    private var weatherDetailsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 15) {
            weatherDetailCard(title: "UV Index", value: "\(weatherData.uvIndex)", icon: "sun.max.fill")
            weatherDetailCard(title: "Wind Speed", value: "\(Int(round(weatherData.windSpeed))) m/s", icon: "wind")
            weatherDetailCard(title: "Humidity", value: "\(weatherData.humidity)%", icon: "humidity")
            weatherDetailCard(title: "Pressure", value: "\(weatherData.pressure) hPa", icon: "gauge")
            weatherDetailCard(title: "Visibility", value: String(format: "%.1f km", weatherData.visibility), icon: "eye.fill")
        }
    }
    
    private func weatherDetailCard(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.headline)
            }
            Text(value)
                .font(.title3)
                .bold()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .foregroundColor(.white)
    }
}

// MARK: - Preview Provider

struct CityWeatherDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CityWeatherDetailView(
            latitude: 51.5074,
            longitude: -0.1278,
            cityName: "London",
            weatherData: WeatherData(
                temperature: 20.5,
                feelsLike: 21.0,
                uvIndex: 5,
                windSpeed: 4.2,
                humidity: 65,
                pressure: 1015,
                visibility: 10.0,
                description: "Partly cloudy",
                hourlyForecast: [
                    HourlyForecast(hour: "Now", temperature: 20.5, icon: "cloud.sun.fill", precipitation: 10),
                    HourlyForecast(hour: "14:00", temperature: 22.0, icon: "sun.max.fill", precipitation: 0),
                    HourlyForecast(hour: "15:00", temperature: 21.5, icon: "cloud.fill", precipitation: 20)
                ]
            )
        )
    }
}

// MARK: - Weather Data Models

struct WeatherData {
    let temperature: Double
    let feelsLike: Double
    let uvIndex: Int
    let windSpeed: Double
    let humidity: Int
    let pressure: Int
    let visibility: Double
    let description: String
    let hourlyForecast: [HourlyForecast]
}

struct HourlyForecast {
    let hour: String
    let temperature: Double
    let icon: String
    let precipitation: Int
}
