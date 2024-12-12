//
//  CityRowView.swift
//  MAD9137_Final Assignment_Weather Application
//
//  Created by Terry Wong on 11/12/2024.
//

import SwiftUI

struct CityRowView: View {
    let city: City
    var onDelete: () -> Void
    @State private var showingDeleteAlert = false
    @State private var currentTime: Date = .init()
    @State private var timer: Timer?
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a" // Changed to 12-hour format with AM/PM
        return formatter
    }()
    
    private func formatTime(_ date: Date) -> String {
        timeFormatter.string(from: date)
    }
    
    private func startTimer() {
        // Calculate seconds until the next minute
        let calendar = Calendar.current
        let seconds = calendar.component(.second, from: Date())
        let delay = 60 - Double(seconds)
        
        // Initial delay to sync with the minute
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            updateTime()
            // Start the timer exactly on the minute
            timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                updateTime()
            }
        }
    }
    
    private func updateTime() {
        currentTime = Date()
    }
    
    // Rest of your view code remains the same...
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
                    
                    Text(formatTime(currentTime))
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.system(size: 20, weight: .bold))
                    }
                    .padding(.bottom, 12)
                    .alert(isPresented: $showingDeleteAlert) {
                        Alert(
                            title: Text("Delete City"),
                            message: Text("Are you sure you want to delete \(city.name)?"),
                            primaryButton: .destructive(Text("Delete")) {
                                onDelete()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    
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
        .onAppear {
            updateTime()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
}
