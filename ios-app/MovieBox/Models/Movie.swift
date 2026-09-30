import Foundation

public struct Movie: Identifiable, Codable, Hashable {
    public var id: String { title }
    public let title: String
    public let cover: String
    public let description: String?
    public let genre: String?
    public let rate: String?
    public let rank: Int?
    public let badge: String?
    public let streamUrl: String?
    
    public init(
        title: String,
        cover: String,
        description: String? = nil,
        genre: String? = nil,
        rate: String? = "8.0",
        rank: Int? = nil,
        badge: String? = nil,
        streamUrl: String? = nil
    ) {
        self.title = title
        self.cover = cover
        self.description = description
        self.genre = genre
        self.rate = rate
        self.rank = rank
        self.badge = badge
        self.streamUrl = streamUrl
    }
}
