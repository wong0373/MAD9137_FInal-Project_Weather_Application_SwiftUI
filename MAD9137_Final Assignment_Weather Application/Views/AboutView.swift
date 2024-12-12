//
//  AboutView.swift
//  MAD9137_Final Assignment_Weather Application
//
//  Created by Terry Wong on 12/12/2024.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Image(systemName: "cloud.sun.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                Text("Weather App")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                
                Text("Version 1.0")
                    .foregroundColor(.white)
                
                Text("© 2024 Your Name")
                    .foregroundColor(.white)
                
                Text("Weather data provided by OpenWeatherMap")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}
