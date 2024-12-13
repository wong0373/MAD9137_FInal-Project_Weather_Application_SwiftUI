import SwiftUI

struct CityRowView: View {
    let city: City
    var onDelete: () -> Void
    @State private var showingDeleteAlert = false
    @State private var currentTime: Date = .init()
    @State private var timer: Timer?
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter
    }()
    
    private func getCurrentLocalTime(for city: City) -> Date {
        guard let timezoneOffset = city.timeZone.flatMap({ Int($0) }) else {
            return Date()
        }
           
        // Get current UTC time
        let currentUTC = Date()
           
        // Add the timezone offset to get local time
        return currentUTC.addingTimeInterval(TimeInterval(timezoneOffset))
    }
       
    private func formatTime(_ date: Date) -> String {
        // Set formatter to UTC to avoid double timezone conversion
        timeFormatter.timeZone = TimeZone(identifier: "UTC")
        return timeFormatter.string(from: date)
    }
       
    private func startTimer() {
        // Update immediately
        updateTime()
           
        // Calculate delay until next minute
        let calendar = Calendar.current
        let seconds = calendar.component(.second, from: Date())
        let delay = 60 - Double(seconds)
           
        // Schedule first update at the start of next minute
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            updateTime()
            // Then update every minute
            timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                updateTime()
            }
        }
    }

    private func updateTime() {
        currentTime = getCurrentLocalTime(for: city)
    }
       
    var body: some View {
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
                .zIndex(1)
                .buttonStyle(PlainButtonStyle())
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
        .contentShape(Rectangle())
        .background(Color.clear)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
}
