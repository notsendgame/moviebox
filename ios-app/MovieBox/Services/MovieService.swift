import Foundation

private struct CatalogItem: Codable {
    let title: String
    let cover: String
    let genre: String?
    let rate: String?
}

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
        "https://macdn.aoneroom.com/media/vone/2026/09/07/08ccf73cb317ae27c8a1ef33fb5c3787-ld.mp4", // Indo drama (Terikat Janji, Tante Sonya)
        "https://macdn.aoneroom.com/media/vone/2024/02/27/69055201aeb921d214209dc92bb7a14e-sd.mp4", // Action comedy (Flex x Cop)
        "https://macdn.aoneroom.com/media/vone/2026/03/03/200bef0612c9fca6a2d43dd3d4831ffa-ld.mp4", // Horror thriller (Sengkolo)
        "https://macdn.aoneroom.com/media/vone/2026/08/07/3a28bc81f68fb975118228b89484877a-ld.mp4", // Action thriller (Project Sacrifice)
        "https://macdn.aoneroom.com/media/vone/2026/08/26/2fea3e3b1047228170dff052f4fcfa23-ld.mp4", // Romance drama (The Early Spring)
        "https://macdn.aoneroom.com/media/vone/2025/01/22/ca6c42d9d955e850e9449fbbc694e250-sd.mp4", // Animation comedy (Win or Lose)
        "https://macdn.aoneroom.com/media/vone/2025/05/29/def24984af12652ad9accb36b851b830-sd.mp4", // Adventure (The Lion King)
        "https://macdn.aoneroom.com/media/vone/2025/10/21/c6e142b36eac69c7c37323158a53c0c4-ld.mp4", // Musical family (Encanto)
        "https://macdn.aoneroom.com/media/vone/2023/10/13/0e545ebd9902492ce849c07572c05f48-sd.mp4", // Sports anime (Captain Tsubasa)
        "https://macdn.aoneroom.com/media/vone/2025/01/10/9efae87a2f8984d2b341b3561bad3039-sd.mp4"  // Animation adventure (Moana)
    ]
    
    public init() {
        loadCatalog()
    }
    
    private func createEpisodes(baseIndex: Int, count: Int = 12) -> [Episode] {
        var eps: [Episode] = []
        for i in 1...count {
            let stream = streamPool[(baseIndex + i - 1) % streamPool.count]
            let hasBadge = (i == 3 || i == 4 || i == 5)
            eps.append(Episode(number: i, streamUrl: stream, duration: "\(40 + (i * 3) % 15):\(10 + (i * 7) % 50)", hasDownloadBadge: hasBadge))
        }
        return eps
    }
    
    public func loadCatalog() {
        // 1. Featured Drama: Terikat Janji (from exact screenshot)
        let terikatJanji = Movie(
            title: "Terikat Janji",
            cover: "https://pbcdnw.aoneroom.com/image/2026/09/17/aec7019b24d1e8faf17e7fd6e22a7658.jpg",
            description: "Dua hati yang dipisahkan oleh takdir dan intrik keluarga konglomerat, berjuang mempertahankan ikatan janji suci di tengah badai pengkhianatan dan rahasia masa lalu.",
            genre: "Tindakan, Drama",
            rate: "6.6",
            year: "2026",
            country: "Indonesia",
            typeTag: "tv",
            seasonInfo: "1 musim",
            rank: 1,
            badge: "VIP",
            uploader: "Diunggah oleh Fatherdmw55 etc.",
            episodes: createEpisodes(baseIndex: 0, count: 16)
        )
        
        let tanteSonya = Movie(
            title: "Tante Sonya",
            cover: "https://pbcdnw.aoneroom.com/image/2026/09/03/b201db9832b0d0c3fe7b735f50cc99a1.jpeg",
            description: "Serial drama romansa yang mengisahkan lika-liku kehidupan Tante Sonya menghadapi masa lalu kelam dan cinta terlarang yang kembali menyapa kehidupannya.",
            genre: "WeTV Original, Drama",
            rate: "9.0",
            year: "2026",
            country: "Indonesia",
            typeTag: "tv",
            seasonInfo: "1 musim",
            rank: 2,
            badge: "WeTV",
            uploader: "Diunggah oleh Fatherdmw55 etc.",
            episodes: createEpisodes(baseIndex: 4, count: 12)
        )
        
        let flexCop = Movie(
            title: "Flex x Cop",
            cover: "https://pbcdnw.aoneroom.com/image/2026/08/04/ab02086490423450ad890217f3d23d2e.jpg",
            description: "Jin Yi-soo, seorang chaebol generasi ketiga yang mendadak bergabung dengan unit kejahatan kekerasan kepolisian. Menggunakan kekayaan dan koneksinya untuk meringkus penjahat yang tak tersentuh hukum.",
            genre: "K-Drama, Action, Comedy",
            rate: "8.9",
            year: "2026",
            country: "Korea",
            typeTag: "tv",
            seasonInfo: "1 musim",
            rank: 3,
            badge: "HOT",
            uploader: "Diunggah oleh Fatherdmw55 etc.",
            episodes: createEpisodes(baseIndex: 1, count: 16)
        )
        
        let sengkolo = Movie(
            title: "Sengkolo: One Suro",
            cover: "https://pbcdnw.aoneroom.com/image/2026/09/09/3643c490708fbd1f22e8917c9a7ee5f0.jpg",
            description: "Teror mistis malam satu suro merenggut ketenangan sebuah desa terpencil saat ritual kuno membangkitkan entitas gelap penuntut balas.",
            genre: "Horor, Misteri",
            rate: "8.6",
            year: "2026",
            country: "Indonesia",
            typeTag: "film",
            seasonInfo: "Lengkap",
            rank: 2,
            badge: "HOT",
            uploader: "Diunggah oleh Fatherdmw55 etc.",
            episodes: createEpisodes(baseIndex: 2, count: 6)
        )
        
        let projectSacrifice = Movie(
            title: "Project Sacrifice",
            cover: "https://pbcdnw.aoneroom.com/image/2026/09/09/9ca742e8ee805d55c933b8bed8949f7d.jpg",
            description: "Eksperimen rahasia militer yang lepas kendali memicu perburuan mematikan antara regu elit dan subjek hasil mutasi genetik.",
            genre: "Thriller, Action",
            rate: "8.5",
            year: "2026",
            country: "Hollywood",
            typeTag: "film",
            seasonInfo: "Lengkap",
            rank: 3,
            uploader: "Diunggah oleh Fatherdmw55 etc.",
            episodes: createEpisodes(baseIndex: 3, count: 6)
        )
        
        let theEarlySpring = Movie(
            title: "The Early Spring",
            cover: "https://pbcdnw.aoneroom.com/image/2026/09/17/6ef3affa71dfec768286dfa1cb7af784.jpg",
            description: "Kisah cinta manis dan melankolis di musim semi antara dua jiwa yang terluka, menemukan harapan baru saat dedaunan mekar kembali.",
            genre: "Romance, Drama",
            rate: "8.4",
            year: "2026",
            country: "China",
            typeTag: "tv",
            seasonInfo: "1 musim",
            rank: 5,
            uploader: "Diunggah oleh Fatherdmw55 etc.",
            episodes: createEpisodes(baseIndex: 4, count: 14)
        )
        
        let winOrLose = Movie(
            title: "Win or Lose",
            cover: "https://pbcdnw.aoneroom.com/image/2026/09/21/0660e094fe638de79f3c38badd7ea01b.jpg",
            description: "Kisah animasi inspiratif regu bisbol sekolah menengah dalam menghadapi pertandingan penentuan kejuaraan antar wilayah.",
            genre: "Animation, Comedy",
            rate: "8.8",
            year: "2025",
            country: "USA",
            typeTag: "tv",
            seasonInfo: "1 musim",
            uploader: "Diunggah oleh Fatherdmw55 etc.",
            episodes: createEpisodes(baseIndex: 5, count: 8)
        )
        
        let bimaSatria = Movie(
            title: "Bima Satria Garuda",
            cover: "https://pbcdnw.aoneroom.com/image/2026/09/17/6ef3affa71dfec768286dfa1cb7af784.jpg",
            description: "Ray Bramasakti berubah menjadi pahlawan super Bima Satria Garuda demi melindungi bumi dari ancaman Kerajaan VUDO.",
            genre: "Tokusatsu, Tindakan",
            rate: "8.7",
            year: "2026",
            country: "Indonesia",
            typeTag: "tv",
            seasonInfo: "1 musim",
            uploader: "Diunggah oleh Fatherdmw55 etc.",
            episodes: createEpisodes(baseIndex: 1, count: 24)
        )
        
        let mahligaiCinta = Movie(
            title: "Mahligai untuk Cinta",
            cover: "https://pbcdnw.aoneroom.com/image/2026/09/25/bdf2a527ad8e31f576fb3ae47583d04d.jpg",
            description: "Rido dan Mutia terperangkap dalam perjodohan rumit yang menguji ketulusan kasih dan pengorbanan mereka demi keluarga.",
            genre: "Drama, Romansa",
            rate: "8.5",
            year: "2026",
            country: "Indonesia",
            typeTag: "tv",
            seasonInfo: "1 musim",
            uploader: "Diunggah oleh Fatherdmw55 etc.",
            episodes: createEpisodes(baseIndex: 0, count: 20)
        )
        
        let sekawanLimo = Movie(
            title: "Sekawan Limo 2",
            cover: "https://pbcdnw.aoneroom.com/image/2026/09/21/0660e094fe638de79f3c38badd7ea01b.jpg",
            description: "Lima sahabat kembali mendaki gunung keramat dan harus mematuhi mitos larangan agar tidak tersesat di alam gaib.",
            genre: "Horror, Comedy",
            rate: "9.1",
            year: "2026",
            country: "Indonesia",
            typeTag: "film",
            seasonInfo: "Lengkap",
            rank: 1,
            badge: "HOT",
            uploader: "Diunggah oleh Fatherdmw55 etc.",
            episodes: createEpisodes(baseIndex: 6, count: 6)
        )

        // Load bundled catalog.json for all 750+ movies
        var fullCatalogList: [Movie] = [
            terikatJanji,
            tanteSonya,
            flexCop,
            sengkolo,
            projectSacrifice,
            theEarlySpring,
            winOrLose,
            bimaSatria,
            mahligaiCinta,
            sekawanLimo
        ]
        
        if let url = Bundle.main.url(forResource: "catalog", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let list = try? JSONDecoder().decode([CatalogItem].self, from: data) {
            
            var existingTitles = Set(fullCatalogList.map { $0.title.lowercased() })
            var index = 5
            for item in list {
                let trimmed = item.title.trimmingCharacters(in: .whitespacesAndNewlines)
                if !existingTitles.contains(trimmed.lowercased()) {
                    existingTitles.insert(trimmed.lowercased())
                    let eps = createEpisodes(baseIndex: index, count: 10)
                    index += 1
                    
                    let isTv = (item.genre?.contains("Drama") ?? false) || (item.genre?.contains("TV") ?? false)
                    
                    let movie = Movie(
                        title: trimmed,
                        cover: item.cover,
                        description: "\(trimmed) streaming kualitas HD/FHD tanpa iklan. Tonton episode lengkap dengan subtitle Indonesia.",
                        genre: item.genre ?? "Drama",
                        rate: item.rate ?? "8.2",
                        year: "2026",
                        country: "Indonesia",
                        typeTag: isTv ? "tv" : "film",
                        seasonInfo: isTv ? "1 musim" : "Lengkap",
                        uploader: "Diunggah oleh Fatherdmw55 etc.",
                        episodes: eps
                    )
                    fullCatalogList.append(movie)
                }
            }
        }
        
        self.allMovies = fullCatalogList
        
        // Hero Banners
        self.heroBanners = [
            terikatJanji,
            Movie(title: "Kupeluk Kamu Selamanya", cover: "https://pbcdnw.aoneroom.com/image/2026/09/21/3dd267f00b7727f38753c79e00054075.jpg", description: "Serial romansa hangat yang menyentuh hati jutaan penonton.", genre: "2026 | Drama", rate: "8.8", year: "2026", episodes: createEpisodes(baseIndex: 4, count: 12)),
            Movie(title: "The Scandal", cover: "https://pbcdnw.aoneroom.com/image/2026/09/14/876fa95f0f03ebdfde01df32676be1fd.jpg", description: "Skandal elit istana yang mengguncang takhta dan kekuasaan.", genre: "2026 | Drama, Romance", rate: "8.5", year: "2026", episodes: createEpisodes(baseIndex: 3, count: 14)),
            sekawanLimo
        ]
        
        // Drama Rankings
        self.dramaRankings = [
            terikatJanji,
            tanteSonya,
            flexCop,
            mahligaiCinta,
            theEarlySpring
        ]
        
        // Movie Rankings
        self.movieRankings = [
            sekawanLimo,
            sengkolo,
            projectSacrifice,
            Movie(title: "Ayah, Ini Arahnya ke Mana?", cover: "https://pbcdnw.aoneroom.com/image/2026/09/09/518028e23d233f569df8b37e2ab7c6d1.jpg", description: "Perjalanan emosional seorang ayah dan anak mencari makna pulang.", genre: "Family, Drama", rate: "8.8", year: "2026", rank: 4, episodes: createEpisodes(baseIndex: 0, count: 6)),
            winOrLose
        ]
        
        self.trendingMovies = Array(self.allMovies.prefix(30))
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
