import Foundation

@MainActor
public class MovieService: ObservableObject {
    @Published public var heroBanners: [Movie] = []
    @Published public var dramaRankings: [Movie] = []
    @Published public var movieRankings: [Movie] = []
    @Published public var trendingMovies: [Movie] = []
    @Published public var allMovies: [Movie] = []
    @Published public var searchResults: [Movie] = []
    @Published public var selectedCategory: String = "Trending"
    @Published public var selectedDramaFilter: String = "All"
    
    public let categories = ["Trending", "Film", "MangoTV", "TV", "Kriket", "Saluran TV"]
    public let dramaFilters = ["All", "K-Drama", "Indo Drama", "C-Drama", "Anime"]
    
    public init() {
        loadCatalog()
    }
    
    public func loadCatalog() {
        // Load bundled catalog.json
        if let url = Bundle.main.url(forResource: "catalog", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let list = try? JSONDecoder().decode([CatalogItem].self, from: data) {
            
            var uniqueMap = [String: Movie]()
            for item in list {
                if uniqueMap[item.title] == nil {
                    uniqueMap[item.title] = Movie(
                        title: item.title,
                        cover: item.cover,
                        genre: item.genre,
                        rate: item.rate,
                        streamUrl: "https://macdn.aoneroom.com/media/vone/2025/01/10/9efae87a2f8984d2b341b3561bad3039-sd.mp4"
                    )
                }
            }
            self.allMovies = Array(uniqueMap.values)
        }
        
        // Setup exact data matching MovieBox Android UI
        self.heroBanners = [
            Movie(title: "Kupeluk Kamu Selamanya", cover: "https://pbcdnw.aoneroom.com/image/2026/09/21/3dd267f00b7727f38753c79e00054075.jpg", genre: "2026 | Drama", rate: "8.8"),
            Movie(title: "The Scandal", cover: "https://pbcdnw.aoneroom.com/image/2026/09/14/876fa95f0f03ebdfde01df32676be1fd.jpg", genre: "2026 | Drama, Romance", rate: "8.5"),
            Movie(title: "Five Friends 2: Mount Klawih", cover: "https://pbcdnw.aoneroom.com/image/2026/09/21/0660e094fe638de79f3c38badd7ea01b.jpg", genre: "2026 | Adventure, Comedy", rate: "8.9")
        ]
        
        // Exact Drama Rankings matching Image 1
        self.dramaRankings = [
            Movie(title: "Terikat Janji", cover: "https://pbcdnw.aoneroom.com/image/2026/09/17/aec7019b24d1e8faf17e7fd6e22a7658.jpg", genre: "Indo Drama", rate: "9.2", rank: 1, badge: "VIP"),
            Movie(title: "Tante Sonya", cover: "https://pbcdnw.aoneroom.com/image/2026/09/03/b201db9832b0d0c3fe7b735f50cc99a1.jpeg", genre: "WeTV Original", rate: "9.0", rank: 2, badge: "WeTV"),
            Movie(title: "Flex x Cop", cover: "https://pbcdnw.aoneroom.com/image/2026/08/04/ab02086490423450ad890217f3d23d2e.jpg", genre: "K-Drama", rate: "8.9", rank: 3, badge: "HOT"),
            Movie(title: "A Bona Fide Killer", cover: "https://pbcdnw.aoneroom.com/image/2026/09/25/bdf2a527ad8e31f576fb3ae47583d04d.jpg", genre: "Action, Crime", rate: "8.7", rank: 4),
            Movie(title: "The Early Spring", cover: "https://pbcdnw.aoneroom.com/image/2026/09/17/6ef3affa71dfec768286dfa1cb7af784.jpg", genre: "Romance", rate: "8.4", rank: 5)
        ]
        
        // Exact Movie Rankings
        self.movieRankings = [
            Movie(title: "Sekawan Limo 2", cover: "https://pbcdnw.aoneroom.com/image/2026/09/21/0660e094fe638de79f3c38badd7ea01b.jpg", genre: "Horror, Comedy", rate: "9.1", rank: 1, badge: "HOT"),
            Movie(title: "Sengkolo: One Suro", cover: "https://pbcdnw.aoneroom.com/image/2026/09/09/3643c490708fbd1f22e8917c9a7ee5f0.jpg", genre: "Horror", rate: "8.6", rank: 2),
            Movie(title: "Project Sacrifice", cover: "https://pbcdnw.aoneroom.com/image/2026/09/09/9ca742e8ee805d55c933b8bed8949f7d.jpg", genre: "Thriller", rate: "8.5", rank: 3),
            Movie(title: "Ayah, Ini Arahnya ke Mana?", cover: "https://pbcdnw.aoneroom.com/image/2026/09/09/518028e23d233f569df8b37e2ab7c6d1.jpg", genre: "Family, Drama", rate: "8.8", rank: 4),
            Movie(title: "Ghost in the Cell", cover: "https://pbcdnw.aoneroom.com/image/2026/09/16/abab6101d274f8d0158bb130c48a95e6.jpg", genre: "Comedy, Horror", rate: "8.3", rank: 5)
        ]
        
        self.trendingMovies = Array(self.allMovies.prefix(20))
        self.searchResults = self.allMovies
    }
    
    public func search(query: String) {
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.searchResults = self.allMovies
        } else {
            self.searchResults = self.allMovies.filter {
                $0.title.localizedCaseInsensitiveContains(query) ||
                ($0.genre?.localizedCaseInsensitiveContains(query) ?? false)
            }
        }
    }
}

struct CatalogItem: Codable {
    let title: String
    let cover: String
    let genre: String?
    let rate: String?
}
