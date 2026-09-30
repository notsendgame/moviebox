import Foundation

public struct Movie: Identifiable, Codable, Hashable {
    public let id: String
    public let title: String
    public let cover: String
    public let description: String?
    public let genre: String?
    public let duration: String?
    public let rate: Double?
    public let releaseDate: String?
    public let streamUrl: String?
    
    public init(
        id: String,
        title: String,
        cover: String,
        description: String? = nil,
        genre: String? = nil,
        duration: String? = nil,
        rate: Double? = nil,
        releaseDate: String? = nil,
        streamUrl: String? = nil
    ) {
        self.id = id
        self.title = title
        self.cover = cover
        self.description = description
        self.genre = genre
        self.duration = duration
        self.rate = rate
        self.releaseDate = releaseDate
        self.streamUrl = streamUrl
    }
}
