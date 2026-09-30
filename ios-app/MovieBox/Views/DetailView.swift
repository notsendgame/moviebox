import SwiftUI

public struct DetailView: View {
    let movie: Movie
    @State private var showingPlayer = false
    
    public init(movie: Movie) {
        self.movie = movie
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header image
                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: URL(string: movie.cover)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            Color.gray.opacity(0.3)
                        }
                    }
                    .frame(height: 380)
                    .clipped()
                    
                    LinearGradient(
                        colors: [.clear, Color(uiColor: .systemBackground)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(movie.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        if let genre = movie.genre {
                            Text(genre)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                }
                
                // Play Button
                Button {
                    showingPlayer = true
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Watch Now")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .fullScreenCover(isPresented: $showingPlayer) {
                    PlayerView(streamUrl: movie.streamUrl ?? "https://macdn.aoneroom.com/media/vone/2025/01/10/9efae87a2f8984d2b341b3561bad3039-sd.mp4")
                }
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Synopsis")
                        .font(.headline)
                    
                    Text(movie.description ?? "Streaming available in multiple resolutions (1080p, 720p, 480p). Enjoy watching on your iPhone with native hardware accelerated playback.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
