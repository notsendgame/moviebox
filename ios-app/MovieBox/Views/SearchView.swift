import SwiftUI

public struct SearchView: View {
    @ObservedObject var movieService: MovieService
    @State private var searchText = ""
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    public init(movieService: MovieService) {
        self.movieService = movieService
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Input Field
                HStack(spacing: 10) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search movies, drama, anime...", text: $searchText)
                            .foregroundColor(.white)
                            .onChange(of: searchText) { newValue in
                                movieService.search(query: newValue)
                            }
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                                movieService.search(query: "")
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color(white: 0.15))
                    .cornerRadius(10)
                    
                    if !searchText.isEmpty {
                        Button("Cancel") {
                            searchText = ""
                            movieService.search(query: "")
                        }
                        .foregroundColor(Color(red: 0.0, green: 0.82, blue: 0.53))
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Results Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(movieService.searchResults) { movie in
                            NavigationLink(destination: DetailView(movie: movie)) {
                                VStack(alignment: .leading, spacing: 6) {
                                    AsyncImage(url: URL(string: movie.cover)) { phase in
                                        if let image = phase.image {
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        } else {
                                            Color.gray.opacity(0.3)
                                        }
                                    }
                                    .frame(height: 150)
                                    .cornerRadius(8)
                                    .clipped()
                                    
                                    Text(movie.title)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    
                                    if let genre = movie.genre {
                                        Text(genre)
                                            .font(.system(size: 10))
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
