import SwiftUI

struct AboutView: View {
    @State private var tapCount = 0
    @State private var showKidPhoto = false
    
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
            .edgesIgnoringSafeArea(.all)
        }
    }

    var body: some View {
        ZStack {
            // Background
            BackgroundView()
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Profile Photo with tap gesture
                    Image(showKidPhoto ? "hiddenPic" : "profilePic")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .clipShape(Circle())
                        .onTapGesture {
                            tapCount += 1
                            if tapCount >= 3 {
                                withAnimation(.spring()) {
                                    showKidPhoto.toggle()
                                }
                                tapCount = 0
                            }
                        }
                  
                        .padding(.top, 30)
                    
                    // Profile Info
                    VStack(spacing: 15) {
                        Text("Terry Wong")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Student ID: 041101011")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    // App Info
                    VStack(spacing: 15) {
                        Text("Version 1.0")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    Text("© 2024 Terry Wong")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .padding()
            }
        }.toolbarBackground(.hidden)
            .navigationTitle("About")
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
            .environmentObject(WeatherViewModel())
    }
}
