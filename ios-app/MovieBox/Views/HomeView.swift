import SwiftUI

public struct HomeView: View {
    @ObservedObject var movieService: MovieService
    @Binding var selectedTab: Int
    
    public init(movieService: MovieService, selectedTab: Binding<Int>) {
        self.movieService = movieService
        self._selectedTab = selectedTab
    }
    
    public var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // 1. Top Search Header
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.down.to.line.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(Color(red: 0.0, green: 0.82, blue: 0.53))
                        
                        Button {
                            selectedTab = 1 // Switch to Search tab
                        } label: {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                Text("True Stalker")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                                Spacer()
                                Text("Mencari")
                                    .foregroundColor(Color(red: 0.0, green: 0.82, blue: 0.53))
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(white: 0.16))
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)
                    
                    // 2. Category Tab Bar
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(movieService.categories, id: \.self) { cat in
                                VStack(spacing: 6) {
                                    Text(cat)
                                        .font(.system(size: 16, weight: movieService.selectedCategory == cat ? .bold : .regular))
                                        .foregroundColor(movieService.selectedCategory == cat ? .white : .gray)
                                    
                                    if movieService.selectedCategory == cat {
                                        Rectangle()
                                            .fill(Color(red: 0.0, green: 0.82, blue: 0.53))
                                            .frame(height: 3)
                                            .cornerRadius(1.5)
                                    } else {
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(height: 3)
                                    }
                                }
                                .onTapGesture {
                                    movieService.selectedCategory = cat
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // 3. Hero Carousel Banner
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(movieService.heroBanners) { banner in
                                NavigationLink(destination: DetailView(movie: banner)) {
                                    ZStack(alignment: .bottomLeading) {
                                        AsyncImage(url: URL(string: banner.cover)) { phase in
                                            if let image = phase.image {
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                            } else {
                                                Color.gray.opacity(0.3)
                                            }
                                        }
                                        .frame(width: 320, height: 200)
                                        .clipped()
                                        .cornerRadius(14)
                                        
                                        LinearGradient(
                                            colors: [.clear, .black.opacity(0.85)],
                                            startPoint: .center,
                                            endPoint: .bottom
                                        )
                                        .cornerRadius(14)
                                        
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(banner.title)
                                                    .font(.system(size: 16, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .lineLimit(1)
                                                
                                                if let genre = banner.genre {
                                                    Text(genre)
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            // Circular Green Play Button
                                            Circle()
                                                .fill(Color(red: 0.0, green: 0.82, blue: 0.53))
                                                .frame(width: 40, height: 40)
                                                .overlay(
                                                    Image(systemName: "play.fill")
                                                        .foregroundColor(.white)
                                                        .font(.system(size: 16))
                                                )
                                        }
                                        .padding()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // 4. "Tonton di TV & Web" Promo Card
                    ZStack {
                        LinearGradient(
                            colors: [Color(red: 0.08, green: 0.25, blue: 0.35), Color(red: 0.05, green: 0.15, blue: 0.2)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .cornerRadius(12)
                        
                        HStack(spacing: 12) {
                            Image(systemName: "tv.fill")
                                .font(.system(size: 28))
                                .foregroundColor(Color(red: 0.0, green: 0.82, blue: 0.53))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Watch on TV & Web")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Official website : https://movieboxhd.net")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Text("Download TV")
                                .font(.system(size: 11, weight: .bold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color(red: 0.0, green: 0.82, blue: 0.53))
                                .foregroundColor(.black)
                                .cornerRadius(14)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                    }
                    .padding(.horizontal)
                    
                    // 5. Peringkat Drama
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Peringkat Drama")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Text("Genre >")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        
                        // Drama Sub-filters
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(movieService.dramaFilters, id: \.self) { filter in
                                    Text(filter)
                                        .font(.system(size: 13, weight: .medium))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .background(movieService.selectedDramaFilter == filter ? Color(white: 0.3) : Color(white: 0.15))
                                        .foregroundColor(movieService.selectedDramaFilter == filter ? .white : .gray)
                                        .cornerRadius(16)
                                        .onTapGesture {
                                            movieService.selectedDramaFilter = filter
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Ranked Drama Cards
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(movieService.dramaRankings) { drama in
                                    RankedMovieCard(movie: drama)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // 6. Peringkat Film
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Peringkat Film")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Text("Genre >")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(movieService.movieRankings) { film in
                                    RankedMovieCard(movie: film)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // 7. More Trending
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Trending Now")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(movieService.trendingMovies) { movie in
                                    NavigationLink(destination: DetailView(movie: movie)) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            AsyncImage(url: URL(string: movie.cover)) { phase in
                                                if let image = phase.image {
                                                    image.resizable().aspectRatio(contentMode: .fill)
                                                } else {
                                                    Color.gray.opacity(0.3)
                                                }
                                            }
                                            .frame(width: 110, height: 160)
                                            .cornerRadius(8)
                                            .clipped()
                                            
                                            Text(movie.title)
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                                .frame(width: 110, alignment: .leading)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 24)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

struct RankedMovieCard: View {
    let movie: Movie
    
    var body: some View {
        NavigationLink(destination: DetailView(movie: movie)) {
            VStack(alignment: .leading, spacing: 6) {
                ZStack(alignment: .bottomTrailing) {
                    ZStack(alignment: .topTrailing) {
                        AsyncImage(url: URL(string: movie.cover)) { phase in
                            if let image = phase.image {
                                image.resizable().aspectRatio(contentMode: .fill)
                            } else {
                                Color.gray.opacity(0.3)
                            }
                        }
                        .frame(width: 120, height: 175)
                        .cornerRadius(8)
                        .clipped()
                        
                        // Badge if exists
                        if let badge = movie.badge {
                            Text(badge)
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(4)
                                .padding(4)
                        }
                    }
                    
                    // Giant Stylized Rank Number (1, 2, 3...)
                    if let rank = movie.rank {
                        Text("\(rank)")
                            .font(.system(size: 64, weight: .heavy, design: .rounded))
                            .foregroundColor(.white.opacity(0.4))
                            .shadow(color: .black, radius: 4, x: 0, y: 2)
                            .offset(x: 4, y: 12)
                    }
                }
                
                Text(movie.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .frame(width: 120, alignment: .leading)
                
                if let genre = movie.genre {
                    Text(genre)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .frame(width: 120, alignment: .leading)
                }
            }
        }
    }
}
