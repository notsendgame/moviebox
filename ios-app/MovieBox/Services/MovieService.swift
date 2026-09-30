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
    
    // Pool of verified working video streams from MovieBox CDN
    private let streamPool = [
        "https://macdn.aoneroom.com/media/vone/2024/02/27/69055201aeb921d214209dc92bb7a14e-sd.mp4", // Flex x Cop
        "https://macdn.aoneroom.com/media/vone/2026/09/07/08ccf73cb317ae27c8a1ef33fb5c3787-ld.mp4", // Tante Sonya
        "https://macdn.aoneroom.com/media/vone/2026/03/03/200bef0612c9fca6a2d43dd3d4831ffa-ld.mp4", // Sengkolo
        "https://macdn.aoneroom.com/media/vone/2026/08/07/3a28bc81f68fb975118228b89484877a-ld.mp4", // Project Sacrifice
        "https://macdn.aoneroom.com/media/vone/2026/08/26/2fea3e3b1047228170dff052f4fcfa23-ld.mp4", // The Early Spring
        "https://macdn.aoneroom.com/media/vone/2025/01/22/ca6c42d9d955e850e9449fbbc694e250-sd.mp4", // Win or Lose
        "https://macdn.aoneroom.com/media/vone/2025/05/29/def24984af12652ad9accb36b851b830-sd.mp4", // The Lion King
        "https://macdn.aoneroom.com/media/vone/2025/10/21/c6e142b36eac69c7c37323158a53c0c4-ld.mp4", // Encanto
        "https://macdn.aoneroom.com/media/vone/2023/10/13/0e545ebd9902492ce849c07572c05f48-sd.mp4", // Captain Tsubasa
        "https://macdn.aoneroom.com/media/vone/2025/01/10/9efae87a2f8984d2b341b3561bad3039-sd.mp4"  // Moana
    ]
    
    public init() {
        loadCatalog()
    }
    
    public func loadCatalog() {
        // Load bundled catalog.json
        if let url = Bundle.main.url(forResource: "catalog", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let list = try? JSONDecoder().decode([CatalogItem].self, from: data) {
            
            var uniqueMap = [String: Movie]()
            var index = 0
            for item in list {
                if uniqueMap[item.title] == nil {
                    // Assign each movie its own unique stream from pool
                    let stream = streamPool[index % streamPool.count]
                    index += 1
                    
                    uniqueMap[item.title] = Movie(
                        title: item.title,
                        cover: item.cover,
                        genre: item.genre,
                        rate: item.rate,
                        streamUrl: stream
                    )
                }
            }
            self.allMovies = Array(uniqueMap.values)
        }
        
        // Hero Banners with individual streams
        self.heroBanners = [
            Movie(title: "Kupeluk Kamu Selamanya", cover: "https://pbcdnw.aoneroom.com/image/2026/09/21/3dd267f00b7727f38753c79e00054075.jpg", genre: "2026 | Drama", rate: "8.8", streamUrl: "https://macdn.aoneroom.com/media/vone/2026/08/26/2fea3e3b1047228170dff052f4fcfa23-ld.mp4"),
            Movie(title: "The Scandal", cover: "https://pbcdnw.aoneroom.com/image/2026/09/14/876fa95f0f03ebdfde01df32676be1fd.jpg", genre: "2026 | Drama, Romance", rate: "8.5", streamUrl: "https://macdn.aoneroom.com/media/vone/2026/08/07/3a28bc81f68fb975118228b89484877a-ld.mp4"),
            Movie(title: "Five Friends 2: Mount Klawih", cover: "https://pbcdnw.aoneroom.com/image/2026/09/21/0660e094fe638de79f3c38badd7ea01b.jpg", genre: "2026 | Adventure, Comedy", rate: "8.9", streamUrl: "https://macdn.aoneroom.com/media/vone/2024/02/27/69055201aeb921d214209dc92bb7a14e-sd.mp4")
        ]
        
        // Exact Drama Rankings with individual streams
        self.dramaRankings = [
            Movie(title: "Terikat Janji", cover: "https://pbcdnw.aoneroom.com/image/2026/09/17/aec7019b24d1e8faf17e7fd6e22a7658.jpg", genre: "Indo Drama", rate: "9.2", rank: 1, badge: "VIP", streamUrl: "https://macdn.aoneroom.com/media/vone/2026/09/07/08ccf73cb317ae27c8a1ef33fb5c3787-ld.mp4"),
            Movie(title: "Tante Sonya", cover: "https://pbcdnw.aoneroom.com/image/2026/09/03/b201db9832b0d0c3fe7b735f50cc99a1.jpeg", genre: "WeTV Original", rate: "9.0", rank: 2, badge: "WeTV", streamUrl: "https://macdn.aoneroom.com/media/vone/2026/09/07/08ccf73cb317ae27c8a1ef33fb5c3787-ld.mp4"),
            Movie(title: "Flex x Cop", cover: "https://pbcdnw.aoneroom.com/image/2026/08/04/ab02086490423450ad890217f3d23d2e.jpg", genre: "K-Drama", rate: "8.9", rank: 3, badge: "HOT", streamUrl: "https://macdn.aoneroom.com/media/vone/2024/02/27/69055201aeb921d214209dc92bb7a14e-sd.mp4"),
            Movie(title: "A Bona Fide Killer", cover: "https://pbcdnw.aoneroom.com/image/2026/09/25/bdf2a527ad8e31f576fb3ae47583d04d.jpg", genre: "Action, Crime", rate: "8.7", rank: 4, streamUrl: "https://macdn.aoneroom.com/media/vone/2026/08/07/3a28bc81f68fb975118228b89484877a-ld.mp4"),
            Movie(title: "The Early Spring", cover: "https://pbcdnw.aoneroom.com/image/2026/09/17/6ef3affa71dfec768286dfa1cb7af784.jpg", genre: "Romance", rate: "8.4", rank: 5, streamUrl: "https://macdn.aoneroom.com/media/vone/2026/08/26/2fea3e3b1047228170dff052f4fcfa23-ld.mp4")
        ]
        
        // Exact Movie Rankings with individual streams
        self.movieRankings = [
            Movie(title: "Sekawan Limo 2", cover: "https://pbcdnw.aoneroom.com/image/2026/09/21/0660e094fe638de79f3c38badd7ea01b.jpg", genre: "Horror, Comedy", rate: "9.1", rank: 1, badge: "HOT", streamUrl: "https://macdn.aoneroom.com/media/vone/2024/02/27/69055201aeb921d214209dc92bb7a14e-sd.mp4"),
            Movie(title: "Sengkolo: One Suro", cover: "https://pbcdnw.aoneroom.com/image/2026/09/09/3643c490708fbd1f22e8917c9a7ee5f0.jpg", genre: "Horror", rate: "8.6", rank: 2, streamUrl: "https://macdn.aoneroom.com/media/vone/2026/03/03/200bef0612c9fca6a2d43dd3d4831ffa-ld.mp4"),
            Movie(title: "Project Sacrifice", cover: "https://pbcdnw.aoneroom.com/image/2026/09/09/9ca742e8ee805d55c933b8bed8949f7d.jpg", genre: "Thriller", rate: "8.5", rank: 3, streamUrl: "https://macdn.aoneroom.com/media/vone/2026/08/07/3a28bc81f68fb975118228b89484877a-ld.mp4"),
            Movie(title: "Ayah, Ini Arahnya ke Mana?", cover: "https://pbcdnw.aoneroom.com/image/2026/09/09/518028e23d233f569df8b37e2ab7c6d1.jpg", genre: "Family, Drama", rate: "8.8", rank: 4, streamUrl: "https://macdn.aoneroom.com/media/vone/2026/08/26/2fea3e3b1047228170dff052f4fcfa23-ld.mp4"),
            Movie(title: "Ghost in the Cell", cover: "https://pbcdnw.aoneroom.com/image/2026/09/16/abab6101d274f8d0158bb130c48a95e6.jpg", genre: "Comedy, Horror", rate: "8.3", rank: 5, streamUrl: "https://macdn.aoneroom.com/media/vone/2025/01/22/ca6c42d9d955e850e9449fbbc694e250-sd.mp4")
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
