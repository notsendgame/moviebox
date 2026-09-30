import Foundation

@MainActor
public class MovieService: ObservableObject {
    @Published public var trendingMovies: [Movie] = []
    @Published public var popularMovies: [Movie] = []
    @Published public var animeMovies: [Movie] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    
    public init() {
        Task {
            await fetchFeed()
        }
    }
    
    public func fetchFeed() async {
        isLoading = true
        errorMessage = nil
        
        let feedUrl = URL(string: "https://h5.aoneroom.com")!
        var request = URLRequest(url: feedUrl)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let html = String(data: data, encoding: .utf8) {
                parseFeed(html: html)
            }
        } catch {
            self.errorMessage = "Failed to load feed: \(error.localizedDescription)"
            loadFallbackData()
        }
        
        isLoading = false
    }
    
    private func parseFeed(html: String) {
        var parsed: [Movie] = []
        
        // Match detail links and covers
        let pattern = "https://h5\\.aoneroom\\.com/detail/([a-zA-Z0-9_-]+)"
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let nsHtml = html as NSString
            let matches = regex.matches(in: html, range: NSRange(location: 0, length: nsHtml.length))
            
            var seen = Set<String>()
            for match in matches {
                let id = nsHtml.substring(with: match.range(at: 1))
                if seen.contains(id) { continue }
                seen.insert(id)
                
                // Human-readable title
                let titleParts = id.split(separator: "-").dropLast()
                let title = titleParts.map { $0.capitalized }.joined(separator: " ")
                
                let movie = Movie(
                    id: id,
                    title: title.isEmpty ? "Movie" : title,
                    cover: "https://pbcdnw.aoneroom.com/image/2026/09/24/07db60e7ee7ac0b0c7877782e7dad079.webp",
                    genre: "Action, Adventure",
                    rate: 8.5
                )
                parsed.append(movie)
            }
        }
        
        if !parsed.isEmpty {
            self.trendingMovies = Array(parsed.prefix(10))
            self.popularMovies = Array(parsed.dropFirst(10).prefix(15))
            self.animeMovies = Array(parsed.dropFirst(25).prefix(10))
        } else {
            loadFallbackData()
        }
    }
    
    private func loadFallbackData() {
        self.trendingMovies = [
            Movie(id: "moana-0ccOXC2Jjca", title: "Moana", cover: "https://pbcdnw.aoneroom.com/image/2024/04/15/f8d2e90d6310428e55fba4e1418cfc36.jpg", description: "In ancient Polynesia, when a terrible curse incurred by Maui reaches Moana's island, she answers the Ocean's call.", genre: "Animation, Adventure", rate: 7.6, streamUrl: "https://macdn.aoneroom.com/media/vone/2025/01/10/9efae87a2f8984d2b341b3561bad3039-sd.mp4"),
            Movie(id: "the-early-spring-2LpemdrrJx5", title: "The Early Spring", cover: "https://pbcdnw.aoneroom.com/image/2026/09/28/d26e8d01ccd85f9de6e2654d27edc511.jpg", genre: "Drama, Romance", rate: 8.1),
            Movie(id: "win-or-lose-QYDwK1orwz3", title: "Win Or Lose", cover: "https://pbcdnw.aoneroom.com/image/2026/08/23/41eb0a05618bc1347db055e80b173320.jpg", genre: "Comedy, Sport", rate: 7.9)
        ]
        self.popularMovies = self.trendingMovies
        self.animeMovies = self.trendingMovies
    }
}
