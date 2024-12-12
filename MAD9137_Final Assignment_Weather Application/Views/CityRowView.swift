//
//  CityRowView.swift
//  MAD9137_Final Assignment_Weather Application
//
//  Created by Terry Wong on 11/12/2024.
//

import SwiftUI

struct CityRowView: View {
    let city: City
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    private func formatTime(_ date: Date) -> String {
        return timeFormatter.string(from: date) + " " + (Calendar.current.component(.hour, from: date) < 12 ? "AM" : "PM")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top, spacing: 0) {
                        Text("\(Int(round(city.temperature)))")
                            .font(.system(size: 72, weight: .light))
                        Text("°C")
                            .font(.system(size: 24, weight: .light))
                            .padding(.top, 12)
                    }
                    .foregroundColor(.white)
                    
                    Text(city.name)
                        .font(.system(size: 32, weight: .regular))
                        .foregroundColor(.white)
                    
                    Text(formatTime(city.localTime))
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Button(action: {
                        // Delete action
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.system(size: 20, weight: .bold))
                    }
                    .padding(.bottom, 12)
                    
                    AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(city.weatherIcon)@2x.png")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                    } placeholder: {
                        ProgressView()
                            .tint(.white)
                    }
                    
                    Text(city.weatherDescription.capitalized)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color.clear)
    }
}

#Preview {
    CityListView()
}
