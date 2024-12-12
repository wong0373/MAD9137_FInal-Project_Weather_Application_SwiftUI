//
//  CityListView.swift
//  MAD9137_Final Assignment_Weather Application
//
//  Created by Terry Wong on 11/12/2024.
//

import SwiftUI

struct CityListView: View {
    @StateObject private var viewModel = WeatherViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.4, green: 0.5, blue: 0.9)
                    .ignoresSafeArea(.all)

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(viewModel.cities) { city in
                            CityRowView(city: city)
                            Rectangle()
                                .fill(Color.white).opacity(0.5)
                                .frame(width: .infinity, height: 2)
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
                        // Add city action
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
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onAppear {
            viewModel.fetchAllCityWeather()
        }
    }
}

#Preview {
    CityListView()
}
