import SwiftUI

struct ContentView: View {
    @EnvironmentObject var weatherViewModel: WeatherViewModel

    var body: some View {
        MainTabView()
            .environmentObject(weatherViewModel)
    }
}
