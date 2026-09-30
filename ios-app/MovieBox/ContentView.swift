import SwiftUI

public struct ContentView: View {
    @StateObject private var movieService = MovieService()
    
    public init() {}
    
    public var body: some View {
        TabView {
            HomeView(movieService: movieService)
                .tabItem {
                    Label("Home", systemImage: "play.rectangle.fill")
                }
            
            NavigationView {
                Text("Search & Library coming soon")
                    .navigationTitle("Search")
            }
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
        }
        .accentColor(.red)
    }
}
