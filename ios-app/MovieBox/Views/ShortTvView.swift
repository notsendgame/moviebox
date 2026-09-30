import SwiftUI
import AVKit

public struct ShortTvItem: Identifiable {
    public let id = UUID()
    public let title: String
    public let episodeText: String
    public let likes: String
    public let comments: String
    public let shares: String
    public let streamUrl: String
}

public struct ShortTvView: View {
    @ObservedObject var movieService: MovieService
    @State private var currentIndex: Int = 0
    @State private var isLiked: [UUID: Bool] = [:]
    
    private let shortItems: [ShortTvItem] = [
        ShortTvItem(
            title: "Bos Dingin Menikahi Gadis Desa",
            episodeText: "Episode 12 • Romansa CEO",
            likes: "148.5K",
            comments: "3.2K",
            shares: "12.8K",
            streamUrl: "https://macdn.aoneroom.com/media/vone/2026/09/07/08ccf73cb317ae27c8a1ef33fb5c3787-ld.mp4"
        ),
        ShortTvItem(
            title: "Pembalasan Sang Pewaris Terbuang",
            episodeText: "Episode 05 • Aksi Konglomerat",
            likes: "92.1K",
            comments: "1.8K",
            shares: "8.4K",
            streamUrl: "https://macdn.aoneroom.com/media/vone/2024/02/27/69055201aeb921d214209dc92bb7a14e-sd.mp4"
        ),
        ShortTvItem(
            title: "Misteri Malam Satu Suro",
            episodeText: "Episode 03 • Horor Indonesia",
            likes: "215.3K",
            comments: "5.6K",
            shares: "34.1K",
            streamUrl: "https://macdn.aoneroom.com/media/vone/2026/03/03/200bef0612c9fca6a2d43dd3d4831ffa-ld.mp4"
        ),
        ShortTvItem(
            title: "Cinta Terlarang Tante Sonya",
            episodeText: "Episode 08 • Drama Romansa",
            likes: "340.2K",
            comments: "11.4K",
            shares: "56.9K",
            streamUrl: "https://macdn.aoneroom.com/media/vone/2026/08/26/2fea3e3b1047228170dff052f4fcfa23-ld.mp4"
        )
    ]
    
    public init(movieService: MovieService) {
        self.movieService = movieService
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $currentIndex) {
                ForEach(Array(shortItems.enumerated()), id: \.element.id) { index, item in
                    ShortTvPlayerCell(item: item, isCurrent: currentIndex == index)
                        .tag(index)
                        .rotationEffect(.degrees(-90))
                        .frame(
                            width: UIScreen.main.bounds.width,
                            height: UIScreen.main.bounds.height
                        )
                }
            }
            .rotationEffect(.degrees(90))
            .frame(
                width: UIScreen.main.bounds.height,
                height: UIScreen.main.bounds.width
            )
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Top Bar
            VStack {
                HStack(spacing: 20) {
                    Text("Mengikuti")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                    
                    VStack(spacing: 4) {
                        Text("Untuk Anda")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        
                        Rectangle()
                            .fill(Color(red: 0.0, green: 0.82, blue: 0.53))
                            .frame(width: 28, height: 3)
                            .cornerRadius(1.5)
                    }
                }
                .padding(.top, 48)
                
                Spacer()
            }
        }
        .ignoresSafeArea()
    }
}

private struct ShortTvPlayerCell: View {
    let item: ShortTvItem
    let isCurrent: Bool
    @State private var player: AVPlayer?
    @State private var isLiked: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color.black
            
            if let player = player {
                VideoPlayer(player: player)
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            }
            
            // Gradient Overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.8)],
                startPoint: .center,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Content Info & Right Actions
            HStack(alignment: .bottom) {
                // Info Text
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(item.episodeText)
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.0, green: 0.82, blue: 0.53))
                }
                .padding(.bottom, 100)
                .padding(.leading, 16)
                
                Spacer()
                
                // Right Action Sidebar
                VStack(spacing: 20) {
                    // Like
                    Button {
                        isLiked.toggle()
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: isLiked ? "heart.fill" : "heart.fill")
                                .font(.system(size: 28))
                                .foregroundColor(isLiked ? .red : .white)
                            Text(item.likes)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Comment
                    VStack(spacing: 4) {
                        Image(systemName: "bubble.right.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.white)
                        Text(item.comments)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    // Share
                    VStack(spacing: 4) {
                        Image(systemName: "arrowshape.turn.up.right.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.white)
                        Text(item.shares)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 100)
                .padding(.trailing, 16)
            }
        }
        .onAppear {
            if isCurrent {
                startPlayback()
            }
        }
        .onChange(of: isCurrent) { active in
            if active {
                startPlayback()
            } else {
                player?.pause()
            }
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
    
    private func startPlayback() {
        if let url = URL(string: item.streamUrl) {
            let p = AVPlayer(url: url)
            self.player = p
            p.play()
        }
    }
}
