import SwiftUI

struct CityListView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @State private var showSearchView = false
    @State private var selectedCity: City?

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                MainContentView(
                    viewModel: self.viewModel,
                    selectedCity: self.$selectedCity
                )
            }
            .navigationBarSetup(
                showSearchView: self.$showSearchView,
                viewModel: self.viewModel
            ).navigationDestination(for: City.self) { city in
                CityWeatherDetailView(city: city, viewModel: self.viewModel)
            }
        }

        .onAppear {
            self.viewModel.fetchAllCityWeather()
        }
    }
}

private struct BackgroundView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 135/255, green: 206/255, blue: 235/255),
                Color(red: 35/255, green: 35/255, blue: 25/255)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea(.all)
    }
}

private struct MainContentView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @Binding var selectedCity: City?

    var body: some View {
        ScrollView {
            VStack {
                LoadingView(isLoading: self.viewModel.isLoading)
                CitiesList(
                    viewModel: self.viewModel,
                    selectedCity: self.$selectedCity
                )
            }
            .padding(.top, 20)
            .scrollIndicators(.hidden)
        }
    }
}

private struct LoadingView: View {
    let isLoading: Bool

    var body: some View {
        if self.isLoading {
            ProgressView()
                .tint(.white)
                .scaleEffect(1.5)
                .padding()
        }
    }
}

private struct CitiesList: View {
    @ObservedObject var viewModel: WeatherViewModel
    @Binding var selectedCity: City?

    var body: some View {
        ForEach(self.viewModel.cities) { city in
            NavigationLink(value: city) {
                VStack(spacing: 0) {
                    CityRowView(
                        city: city,
                        onDelete: { self.viewModel.deleteCity(city) }
                    )
                    DividerView()
                }
                .tint(.white)
            }
        }
    }
}

private struct DividerView: View {
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.5))
            .frame(width: 370, height: 2)
            .padding(.horizontal, 20)
    }
}

private struct AddButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: self.action) {
            ZStack {
                Circle()
                    .foregroundColor(.white)
                    .frame(width: 25, height: 25)
                Image(systemName: "plus")
                    .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.9))
                    .font(.subheadline)
            }
        }
    }
}

private extension View {
    func navigationBarSetup(showSearchView: Binding<Bool>, viewModel: WeatherViewModel) -> some View {
        self
            .navigationTitle("Algonquin Weather")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    AddButton {
                        showSearchView.wrappedValue = true
                    }
                }
            }
            .sheet(isPresented: showSearchView) {
                SearchCityView()
                    .environmentObject(viewModel)
            }
            .toolbarBackground(.hidden)
    }
}

struct CityListView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(WeatherViewModel())
    }
}
