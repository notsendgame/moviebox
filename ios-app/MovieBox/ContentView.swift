import SwiftUI

public struct ContentView: View {
    @StateObject private var movieService = MovieService()
    @State private var selectedTab = 0
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(movieService: movieService, selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Beranda")
                }
                .tag(0)
            
            SearchView(movieService: movieService)
                .tabItem {
                    Image(systemName: "play.rectangle.fill")
                    Text("ShortTV")
                }
                .tag(1)
            
            VStack(spacing: 16) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.yellow)
                Text("MovieBox VIP")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Bebas iklan, download cepat & resolusi 4K Ultra HD.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.ignoresSafeArea())
            .tabItem {
                Image(systemName: "crown.fill")
                Text("Premium")
            }
            .tag(2)
            
            VStack(spacing: 16) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(Color(red: 0.0, green: 0.82, blue: 0.53))
                Text("Daftar Unduhan")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Belum ada video yang diunduh.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.ignoresSafeArea())
            .tabItem {
                Image(systemName: "arrow.down.circle")
                Text("Unduhan")
            }
            .tag(3)
            
            VStack(spacing: 16) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.gray)
                Text("Profil Saya")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("MovieBox v1.0.2 for iOS")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.ignoresSafeArea())
            .tabItem {
                Image(systemName: "person.fill")
                Text("Aku")
            }
            .tag(4)
        }
        .accentColor(Color(red: 0.0, green: 0.82, blue: 0.53))
    }
}
