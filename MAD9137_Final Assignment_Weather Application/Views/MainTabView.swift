import SwiftUI

struct MainTabView: View {
    @StateObject private var weatherViewModel = WeatherViewModel()

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground() // Makes the tab bar transparent
        appearance.backgroundColor = .clear

        // For iOS 15 and later
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().standardAppearance = appearance

        // Remove the tab bar border
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
    }

    var body: some View {
        TabView {
            CityListView()
                .environmentObject(weatherViewModel)
                .tabItem {
                    Image(systemName: "building.2")
                    Text("Cities")
                }

            SettingsView()
                .environmentObject(weatherViewModel)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .accentColor(.white)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
