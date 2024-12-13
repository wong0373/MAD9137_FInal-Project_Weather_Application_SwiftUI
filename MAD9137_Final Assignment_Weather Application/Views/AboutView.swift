import SwiftUI

struct AboutView: View {
    @State private var tapCount = 0
    @State private var showKidPhoto = false

    var body: some View {
        ZStack {
            BackgroundView()

            ScrollView {
                VStack(alignment: .center, spacing: 40) {
                    Image(showKidPhoto ? "hiddenPic" : "profilePic")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .shadow(radius: 10, x: 0, y: 5)
                        .overlay(
                            Circle()
                                .stroke(.white, lineWidth: 2) // Add a white border
                        )
                        .onTapGesture {
                            tapCount += 1
                            if tapCount >= 3 {
                                withAnimation(.spring()) {
                                    showKidPhoto.toggle()
                                }
                                tapCount = 0
                            }
                        }
                        .padding(.top, 60)

                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Terry Wong")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Button(action: {
                                if let url = URL(string: "mailto:wong0373@algonquinlive.com") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Text("wong0373@algonquinlive.com")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .underline()
                            }

                            Link("Github: wong0373", destination: URL(string: "https://github.com/wong0373")!)
                                .font(.headline)
                                .foregroundColor(.white)
                                .underline()
                        }
                        .padding(.leading, 20)
                    }

                    Divider()
                        .background(Color.white.opacity(0.9))
                        .padding(.horizontal, 40)

                    VStack(spacing: 10) {
                        Text("Version 1.0")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text("© 2024 Terry Wong")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .padding()
            }
        }
        .toolbarBackground(.hidden)
        .navigationTitle("About")
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
