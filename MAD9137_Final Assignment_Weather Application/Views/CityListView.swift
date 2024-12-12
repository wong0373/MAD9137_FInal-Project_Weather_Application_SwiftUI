//
//  CityListView.swift
//  MAD9137_Final Assignment_Weather Application
//
//  Created by Terry Wong on 11/12/2024.
//

import SwiftUI

struct CityListView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @State private var showSearchView = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.4, green: 0.5, blue: 0.9)
                    .ignoresSafeArea(.all)

                ScrollView {
                    VStack(spacing: 0) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(1.5)
                                .padding()
                        }
                        ForEach(viewModel.cities) { city in
                            CityRowView(city: city, onDelete: {
                                viewModel.deleteCity(city)
                            })
                            Rectangle()
                                .fill(Color.white).opacity(0.5)
                                .frame(width: 370, height: 2)
                                .padding(.horizontal, 20)
                        }
                    }.background(Color.clear)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Algonquin Weather")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(red: 0.4, green: 0.5, blue: 0.9), for: .navigationBar)
            .toolbarBackground(.visible)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showSearchView = true
                    }) {
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
            }.sheet(isPresented: $showSearchView) {
                SearchCityView()
                    .environmentObject(viewModel)
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onAppear {
            viewModel.fetchAllCityWeather()
        }
    }
}

struct CityListView_Previews: PreviewProvider {
    static var previews: some View {
        CityListView()
            .environmentObject(WeatherViewModel())
    }
}
