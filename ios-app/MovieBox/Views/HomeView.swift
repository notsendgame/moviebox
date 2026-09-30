import SwiftUI

public struct HomeView: View {
    @ObservedObject var movieService: MovieService
    
    public init(movieService: MovieService) {
        self.movieService = movieService
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Featured Banner
                    if let featured = movieService.trendingMovies.first {
                        NavigationLink(destination: DetailView(movie: featured)) {
                            ZStack(alignment: .bottomLeading) {
                                AsyncImage(url: URL(string: featured.cover)) { phase in
                                    if let image = phase.image {
                                        image.resizable().aspectRatio(contentMode: .fill)
                                    } else {
                                        Color.gray.opacity(0.3)
                                    }
                                }
                                .frame(height: 260)
                                .clipped()
                                .cornerRadius(16)
                                
                                LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                                    .cornerRadius(16)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("FEATURED")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                    Text(featured.title)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                .padding()
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Trending Section
                    MovieSection(title: "🔥 Trending Movies", movies: movieService.trendingMovies)
                    
                    // Popular Section
                    MovieSection(title: "🍿 Popular Now", movies: movieService.popularMovies)
                    
                    // Anime Section
                    MovieSection(title: "✨ Animation & Anime", movies: movieService.animeMovies)
                }
                .padding(.vertical)
            }
            .navigationTitle("MovieBox")
            .refreshable {
                await movieService.fetchFeed()
            }
        }
    }
}

struct MovieSection: View {
    let title: String
    let movies: [Movie]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 14) {
                    ForEach(movies) { movie in
                        NavigationLink(destination: DetailView(movie: movie)) {
                            VStack(alignment: .leading, spacing: 6) {
                                AsyncImage(url: URL(string: movie.cover)) { phase in
                                    if let image = phase.image {
                                        image.resizable().aspectRatio(contentMode: .fill)
                                    } else {
                                        Color.gray.opacity(0.3)
                                    }
                                }
                                .frame(width: 130, height: 190)
                                .cornerRadius(10)
                                .clipped()
                                
                                Text(movie.title)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                                    .frame(width: 130, alignment: .leading)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
