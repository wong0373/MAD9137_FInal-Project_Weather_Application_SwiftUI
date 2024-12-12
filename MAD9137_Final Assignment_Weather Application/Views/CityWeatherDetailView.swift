import MapKit
import SwiftUI

struct CityWeatherDetailView: View {
    let city: City
    @ObservedObject var viewModel: WeatherViewModel
    @Environment(\.dismiss) private var dismiss
    
    struct MapView: UIViewRepresentable {
        let coordinate: CLLocationCoordinate2D
        
        func makeUIView(context: Context) -> MKMapView {
            let mapView = MKMapView()
            mapView.showsUserLocation = false
            mapView.isZoomEnabled = false // Disable zoom
            mapView.isScrollEnabled = false // Disable scroll
            mapView.isRotateEnabled = false
            
            mapView.pointOfInterestFilter = .excludingAll
            return mapView
        }
        
        func updateUIView(_ uiView: MKMapView, context: Context) {
            let region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03) // Adjust zoom level
            )
            uiView.setRegion(region, animated: true)
              
            // Apply custom appearance
            if let overlay = uiView.overlays.first {
                uiView.removeOverlay(overlay)
            }
        }
    }
    
    var body: some View {
        ScrollView {
            ZStack {
                // Background layers
                MapView(coordinate: CLLocationCoordinate2D(
                    latitude: city.coordinates.lat,
                    longitude: city.coordinates.lon
                ))
                .ignoresSafeArea()
                    
                // Overlay layers
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.4),
                        Color.black.opacity(0.2),
                        Color.clear
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                    
                // Content
                VStack(spacing: 25) {
                    // Top Navigation
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                        Spacer()
                            
                        Button(action: {}) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                        
                    // Location Info
                    VStack(spacing: 8) {
                        Text(city.name)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            
                        Text("\(city.country) • \(formatDate(city.localTime))")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 10)
                        
                    // Current Weather
                    VStack(spacing: 15) {
                        AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(city.weatherIcon)@2x.png")) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        } placeholder: {
                            ProgressView()
                        }
                            
                        Text("\(Int(city.temperature))°")
                            .font(.system(size: 80, weight: .thin))
                            .foregroundColor(.white)
                            
                        Text(city.weatherDescription.capitalized)
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.vertical, 20)
                        
                    // Weather Details Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        WeatherDetailCard(icon: "thermometer", title: "Feels Like", value: "\(Int(city.temperature))°")
                        WeatherDetailCard(icon: "humidity", title: "Humidity", value: "N/A%")
                        WeatherDetailCard(icon: "wind", title: "Wind Speed", value: "N/A km/h")
                        WeatherDetailCard(icon: "gauge", title: "Pressure", value: "N/A hPa")
                    }
                    .padding(.horizontal)
                        
                    // Hourly Forecast
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Hourly Forecast")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(0 ..< 24) { hour in
                                    HourlyForecastItem(hour: hour)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top, 50)
            }
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
    }
        
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM"
        return formatter.string(from: date)
    }
}

// Weather Detail Card Component
struct WeatherDetailCard: View {
    let icon: String
    let title: String
    let value: String
        
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                
            Text(title)
                .font(.callout)
                .foregroundColor(.white.opacity(0.7))
                
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .opacity(0.3)
        )
    }
}

// Hourly Forecast Item
struct HourlyForecastItem: View {
    let hour: Int
        
    var body: some View {
        VStack(spacing: 10) {
            Text("\(hour):00")
                .font(.callout)
                .foregroundColor(.white)
                
            Image(systemName: "cloud.sun.fill")
                .font(.title2)
                .foregroundColor(.white)
                
            Text("24°")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .opacity(0.3)
        )
    }
}

struct CityWeatherDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CityWeatherDetailView(
            city: City(
                name: "New York",
                temperature: 25.0,
                weatherDescription: "Clear sky",
                weatherIcon: "01d",
                localTime: Date(),
                country: "US",
                timeZone: "America/New_York",
                coordinates: Coordinates(lat: 40.7128, lon: -74.0060)
            ),
            viewModel: WeatherViewModel()
        )
    }
}
