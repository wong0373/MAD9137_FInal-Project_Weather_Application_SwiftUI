import MapKit
import SwiftUI

struct CityWeatherDetailView: View {
    let city: City
    @ObservedObject var viewModel: WeatherViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isCelsius = true
    
    var body: some View {
        ZStack {
            color(for: city.temperature)
                .ignoresSafeArea()
                        
            MapView(coordinate: CLLocationCoordinate2D(
                latitude: city.coordinates.lat,
                longitude: city.coordinates.lon
            ))
            .ignoresSafeArea()
           
            LinearGradient(
                gradient: Gradient(colors: [
                    color(for: city.temperature).opacity(1.2),
                    color(for: city.temperature).opacity(0.7),
                    color(for: city.temperature).opacity(0.6),
                    color(for: city.temperature).opacity(0.4),
                    color(for: city.temperature).opacity(0.2),
                    color(for: city.temperature).opacity(0.1),
         
                ]),
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    navigationBar
                    weatherInfo
                    weatherDetails
                    hourlyForecast
                }
                .padding(.horizontal)
            }
        }
        .navigationBarHidden(true)
        .task {
            print("Starting forecast fetch for \(city.name)")
            await viewModel.fetchForecast(for: city)
            print("Forecast data count: \(viewModel.hourlyForecast.count)")
        }
    }

    private func convertTemperature(_ celsius: Double) -> Double {
        return isCelsius ? celsius : (celsius * 9 / 5) + 32
    }
    
    private func color(for temperature: Double) -> Color {
        let normalized = (temperature + 30) / 70
        return Color(
            hue: (1.0 - normalized) * 2 / 3,
            saturation: 1.0,
            brightness: 0.7
        )
    }
    
    private var navigationBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.black.opacity(0.8))
                    .padding(18)
                    .background(Color.white.opacity(0.4))
                    .clipShape(Circle())
            }
            
            Spacer()
        }
    }
    
    private var weatherInfo: some View {
        VStack(spacing: 24) {
            Text(city.name)
                .font(.system(size: 50, weight: .semibold))
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Modified temperature display with toggle
            VStack {
                Text("\(Int(round(convertTemperature(city.temperature))))°\(isCelsius ? "C" : "F")")
                    .font(.system(size: 120, weight: .semibold))
                    .foregroundColor(.white)
                    .onTapGesture {
                        isCelsius.toggle()
                    }
            }
            
            Text("\(formatDate(city.localTime))")
                .font(.system(size: 30, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.bottom, 40)
    }
  
    private var weatherDetails: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            HStack(spacing: 13) {
                WeatherDetailCard(icon: "wind", title: "Wind", value: "\(Int(city.windSpeed)) m/s")
                WeatherDetailCard(icon: "humidity", title: "Humidity", value: "\(city.humidity)%")
            }
        }
    }
    
    private var hourlyForecast: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("5-Day Forecast")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                   
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(viewModel.hourlyForecast) { forecast in
                        HourlyForecastCard(
                            hour: formatForecastTime(forecast.time),
                            temperature: Int(forecast.temperature),
                            icon: forecast.icon
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM"
        return formatter.string(from: date)
    }

    private func formatHour(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:00"
        return formatter.string(from: date)
    }
}

struct MapView: UIViewRepresentable {
    let coordinate: CLLocationCoordinate2D
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isRotateEnabled = false
        mapView.pointOfInterestFilter = .excludingAll
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07)
        )
        uiView.setRegion(region, animated: true)
        
        if let overlay = uiView.overlays.first {
            uiView.removeOverlay(overlay)
        }
    }
}

private func formatForecastTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm\nMM/dd"
    return formatter.string(from: date)
}

struct WeatherDetailCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

struct HourlyForecastCard: View {
    let hour: String
    let temperature: Int
    let icon: String
    
    var body: some View {
        VStack(spacing: 10) {
            Text(hour)
                .font(.callout)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            } placeholder: {
                Image(systemName: "cloud.sun.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            Text("\(temperature)°")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
}

struct CityWeatherDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CityWeatherDetailView(
            city: City(
                name: "New York",
                temperature: 12.0,
                weatherDescription: "Clear sky",
                weatherIcon: "01d",
                localTime: Date(),
                country: "US",
                timeZone: "America/New_York",
                coordinates: Coordinates(lat: 40.7128, lon: -74.0060),
                humidity: 65,
                windSpeed: 5.2
                
            ),
            viewModel: WeatherViewModel()
        )
    }
}
