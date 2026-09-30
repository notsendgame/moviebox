import SwiftUI

public struct ContentView: View {
    @StateObject private var movieService = MovieService()
    @State private var selectedTab = 0
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 0: Beranda
            HomeView(movieService: movieService, selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Beranda")
                }
                .tag(0)
            
            // Tab 1: ShortTV (Vertical micro-drama swipeable player like MovieBox Android)
            ShortTvView(movieService: movieService)
                .tabItem {
                    Image(systemName: "play.rectangle.fill")
                    Text("ShortTV")
                }
                .tag(1)
            
            // Tab 2: VIP / Premium Unlocked (MOD Feature)
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.94, green: 0.83, blue: 0.58).opacity(0.15))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "crown.fill")
                        .font(.system(size: 64))
                        .foregroundColor(Color(red: 0.94, green: 0.83, blue: 0.58))
                }
                
                Text("MovieBox VIP Unlocked")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color(red: 0.0, green: 0.82, blue: 0.53))
                        Text("Resolusi 1080P & 4K Terbuka Otomatis")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .medium))
                        Spacer()
                    }
                    
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color(red: 0.0, green: 0.82, blue: 0.53))
                        Text("Bebas Seluruh Iklan (Ad-Free Streaming)")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .medium))
                        Spacer()
                    }
                    
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color(red: 0.0, green: 0.82, blue: 0.53))
                        Text("Kecepatan Unduh Maksimal Tanpa Batas")
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: .medium))
                        Spacer()
                    }
                }
                .padding(20)
                .background(Color(white: 0.12))
                .cornerRadius(16)
                .padding(.horizontal, 24)
                
                Text("Status: VIP Lifetime Member Aktif")
                    .font(.footnote)
                    .foregroundColor(Color(red: 0.0, green: 0.82, blue: 0.53))
                    .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.07, green: 0.07, blue: 0.08).ignoresSafeArea())
            .tabItem {
                Image(systemName: "crown.fill")
                Text("VIP")
            }
            .tag(2)
            
            // Tab 3: Unduhan
            VStack(spacing: 16) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(Color(red: 0.0, green: 0.82, blue: 0.53))
                Text("Daftar Unduhan Offline")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Semua video yang kamu unduh akan tersimpan di sini dan dapat ditonton tanpa koneksi internet.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.07, green: 0.07, blue: 0.08).ignoresSafeArea())
            .tabItem {
                Image(systemName: "arrow.down.circle")
                Text("Unduhan")
            }
            .tag(3)
            
            // Tab 4: Profil Saya
            VStack(spacing: 16) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 72))
                    .foregroundColor(Color(white: 0.4))
                Text("MovieBox Member")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("MovieBox iOS Edition v1.0.5")
                    .font(.caption)
                    .foregroundColor(Color(red: 0.0, green: 0.82, blue: 0.53))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.07, green: 0.07, blue: 0.08).ignoresSafeArea())
            .tabItem {
                Image(systemName: "person.fill")
                Text("Aku")
            }
            .tag(4)
        }
        .accentColor(Color(red: 0.0, green: 0.82, blue: 0.53))
    }
}
