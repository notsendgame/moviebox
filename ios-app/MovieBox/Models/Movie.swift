import Foundation

public struct Episode: Identifiable, Codable, Hashable {
    public var id: Int { number }
    public let number: Int
    public var title: String { String(format: "%02d", number) }
    public let streamUrl: String
    public let duration: String?
    public let hasDownloadBadge: Bool
    
    public init(number: Int, streamUrl: String, duration: String? = "45:20", hasDownloadBadge: Bool = false) {
        self.number = number
        self.streamUrl = streamUrl
        self.duration = duration
        self.hasDownloadBadge = hasDownloadBadge
    }
}

public struct Movie: Identifiable, Codable, Hashable {
    public var id: String { title }
    public let title: String
    public let cover: String
    public let description: String?
    public let genre: String?
    public let rate: String?
    public let year: String?
    public let country: String?
    public let typeTag: String? // "tv" or "film"
    public let seasonInfo: String? // "1 musim", "2 musim", "Lengkap"
    public let rank: Int?
    public let badge: String?
    public let uploader: String?
    public let episodes: [Episode]
    
    public var defaultStreamUrl: String {
        episodes.first?.streamUrl ?? "https://macdn.aoneroom.com/media/vone/2026/09/07/08ccf73cb317ae27c8a1ef33fb5c3787-ld.mp4"
    }
    
    public var streamUrl: String? {
        defaultStreamUrl
    }
    
    public init(
        title: String,
        cover: String,
        description: String? = nil,
        genre: String? = nil,
        rate: String? = "8.0",
        year: String? = "2026",
        country: String? = "Indonesia",
        typeTag: String? = "tv",
        seasonInfo: String? = "1 musim",
        rank: Int? = nil,
        badge: String? = nil,
        uploader: String? = "Diunggah oleh Fatherdmw55 etc.",
        episodes: [Episode] = []
    ) {
        self.title = title
        self.cover = cover
        self.description = description
        self.genre = genre
        self.rate = rate
        self.year = year
        self.country = country
        self.typeTag = typeTag
        self.seasonInfo = seasonInfo
        self.rank = rank
        self.badge = badge
        self.uploader = uploader
        self.episodes = episodes
    }
}
