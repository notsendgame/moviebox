import SwiftUI
import AVKit

public struct DetailView: View {
    let movie: Movie
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedEpisode: Episode?
    @State private var player: AVPlayer?
    @State private var isPlaying: Bool = true
    @State private var isMuted: Bool = false
    @State private var selectedTab: Int = 0 // 0: Untukmu, 1: Komentar
    @State private var isFullScreen: Bool = false
    @State private var isBookmarked: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var showDownloadSheet: Bool = false
    @State private var selectedResolution: String = "1080P FHD"
    @State private var showDownloadToast: Bool = false
    
    // Sample comments
    private let comments = [
        ("Budi Santoso", "3 jam lalu", "Aktingnya Arya Saloka keren banget di series ini! Bikin baper parah 🔥", 142),
        ("Siti Rahma", "5 jam lalu", "Episode 2 kapan lanjut min? Seru banget ceritanya ga ngebosenin.", 89),
        ("Dimas Pratama", "1 hari lalu", "Kualitas videonya jernih banget, ga ada buffering sama sekali mantap MovieBox!", 210),
        ("Anisa Putri", "2 hari lalu", "Fix jadi drama favorit tahun ini. Rekomended banget ditonton rame-rame.", 64)
    ]
    
    public init(movie: Movie) {
        self.movie = movie
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 0.07, green: 0.07, blue: 0.08).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. Top Video Player (16:9)
                playerSection
                    .frame(height: 220)
                    .background(Color.black)
                
                // 2. Scrollable Detail Content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        
                        // Subject Info Header
                        headerInfoSection
                            .padding(.horizontal, 16)
                            .padding(.top, 14)
                        
                        // Action Buttons Bar (Tambahkan ke daftar, Membagikan, Unduh)
                        actionButtonsSection
                            .padding(.horizontal, 16)
                        
                        // Sumber daya (Uploader & Audio)
                        resourceSection
                            .padding(.horizontal, 16)
                        
                        // Episode / Part Selector Strip
                        episodeSelectorSection
                            .padding(.horizontal, 16)
                        
                        Divider()
                            .background(Color(white: 0.2))
                            .padding(.horizontal, 16)
                            .padding(.top, 6)
                        
                        // Tab Selector (Untukmu / Komentar)
                        tabSelectorSection
                            .padding(.horizontal, 16)
                        
                        // Tab Content
                        if selectedTab == 0 {
                            recommendationsGrid
                                .padding(.horizontal, 16)
                        } else {
                            commentsSection
                                .padding(.horizontal, 16)
                        }
                        
                        Spacer(minLength: 80) // Spacing for floating bottom button
                    }
                }
            }
            
            // 3. Floating Download Button at bottom (matching Android MovieBox)
            floatingDownloadButton
                .padding(.bottom, 12)
            
            // 4. Download Confirmation Toast
            if showDownloadToast {
                VStack {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(red: 0.0, green: 0.82, blue: 0.53))
                        Text("Unduhan dimulai! Tersimpan di tab Unduhan.")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(white: 0.18))
                    .cornerRadius(24)
                    .shadow(radius: 10)
                    .padding(.bottom, 70)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            setupInitialEpisode()
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
        .fullScreenCover(isPresented: $isFullScreen) {
            if let ep = selectedEpisode {
                PlayerView(streamUrl: ep.streamUrl)
            }
        }
        .sheet(isPresented: $showDownloadSheet) {
            downloadBottomSheet
        }
    }
    
    // MARK: - Video Player View
    private var playerSection: some View {
        ZStack(alignment: .topLeading) {
            if let player = player {
                VideoPlayer(player: player)
                    .aspectRatio(16/9, contentMode: .fit)
            } else {
                ZStack {
                    Color.black
                    ProgressView()
                        .tint(Color(red: 0.2, green: 0.8, blue: 0.6))
                }
            }
            
            // Player Top Overlay (Back button & Fullscreen button)
            HStack {
                Button {
                    player?.pause()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                // Fullscreen Toggle
                Button {
                    isFullScreen = true
                } label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
        }
    }
    
    // MARK: - Header Info Section
    private var headerInfoSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(movie.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Informasi >")
                    .font(.system(size: 13))
                    .foregroundColor(Color(white: 0.6))
            }
            
            // Metadata Line (tv | ⭐ 6.6 | 2026 | Indonesia | Tindakan | 1 musim)
            HStack(spacing: 6) {
                Text(movie.typeTag ?? "tv")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(Color(white: 0.25))
                    .foregroundColor(.white)
                    .cornerRadius(3)
                
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 11))
                        .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.2))
                    Text(movie.rate ?? "6.6")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(red: 0.95, green: 0.77, blue: 0.2))
                }
                
                Text("|")
                    .foregroundColor(Color(white: 0.4))
                    .font(.system(size: 11))
                
                Text(movie.year ?? "2026")
                    .font(.system(size: 12))
                    .foregroundColor(Color(white: 0.7))
                
                Text("|")
                    .foregroundColor(Color(white: 0.4))
                    .font(.system(size: 11))
                
                Text(movie.country ?? "Indonesia")
                    .font(.system(size: 12))
                    .foregroundColor(Color(white: 0.7))
                
                Text("|")
                    .foregroundColor(Color(white: 0.4))
                    .font(.system(size: 11))
                
                Text(movie.genre ?? "Tindakan")
                    .font(.system(size: 12))
                    .foregroundColor(Color(white: 0.7))
                    .lineLimit(1)
                
                Text("|")
                    .foregroundColor(Color(white: 0.4))
                    .font(.system(size: 11))
                
                Text(movie.seasonInfo ?? "1 musim")
                    .font(.system(size: 12))
                    .foregroundColor(Color(white: 0.7))
            }
        }
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        HStack(spacing: 10) {
            // Tambahkan ke daftar
            Button {
                isBookmarked.toggle()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: isBookmarked ? "checkmark" : "plus")
                        .font(.system(size: 13, weight: .bold))
                    Text("Tambahkan ke daftar")
                        .font(.system(size: 13, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(Color(white: 0.18))
                .foregroundColor(.white)
                .cornerRadius(19)
            }
            
            // Membagikan
            Button {
                showShareSheet = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrowshape.turn.up.right")
                        .font(.system(size: 13, weight: .bold))
                    Text("Membagikan")
                        .font(.system(size: 13, weight: .medium))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(Color(white: 0.18))
                .foregroundColor(.white)
                .cornerRadius(19)
            }
            
            // Unduh (Golden button)
            Button {
                showDownloadSheet = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "bag.badge.plus")
                        .font(.system(size: 13, weight: .bold))
                    Text("Unduh")
                        .font(.system(size: 13, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(Color(red: 0.94, green: 0.83, blue: 0.58))
                .foregroundColor(Color(red: 0.25, green: 0.18, blue: 0.05))
                .cornerRadius(19)
            }
        }
    }
    
    // MARK: - Sumber Daya Section
    private var resourceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text("Sumber daya")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                
                Text(movie.uploader ?? "Diunggah oleh Fatherdmw55 etc.")
                    .font(.system(size: 12))
                    .foregroundColor(Color(white: 0.6))
                
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 12))
                    .foregroundColor(Color(white: 0.5))
            }
            
            // Audio Option Pill
            HStack {
                Text("Original Audio")
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(white: 0.6))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(white: 0.18))
            .cornerRadius(14)
        }
    }
    
    // MARK: - Episode / Part Selector Strip
    private var episodeSelectorSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // Genre chip
                Text("Genre")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(white: 0.8))
                    .frame(width: 58, height: 44)
                    .background(Color(white: 0.16))
                    .cornerRadius(8)
                
                // Episode Chips ("01", "02", "03", "04", ...)
                ForEach(movie.episodes) { ep in
                    let isSelected = selectedEpisode?.number == ep.number
                    
                    Button {
                        playEpisode(ep)
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Text(ep.title)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(isSelected ? Color(red: 0.2, green: 0.85, blue: 0.6) : Color(white: 0.85))
                                .frame(width: 58, height: 44)
                                .background(
                                    isSelected
                                        ? Color(red: 0.08, green: 0.22, blue: 0.21)
                                        : Color(white: 0.16)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(isSelected ? Color(red: 0.2, green: 0.65, blue: 0.5) : Color.clear, lineWidth: 1.5)
                                )
                                .cornerRadius(8)
                            
                            // Tiny download bag badge if applicable
                            if ep.hasDownloadBadge {
                                Image(systemName: "bag.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(Color(red: 0.94, green: 0.83, blue: 0.58))
                                    .padding(4)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Tab Selector Section (Untukmu / Komentar)
    private var tabSelectorSection: some View {
        HStack(spacing: 24) {
            // Tab 1: Untukmu
            Button {
                selectedTab = 0
            } label: {
                VStack(spacing: 6) {
                    Text("Untukmu")
                        .font(.system(size: 16, weight: selectedTab == 0 ? .bold : .regular))
                        .foregroundColor(selectedTab == 0 ? .white : Color(white: 0.6))
                    
                    if selectedTab == 0 {
                        Rectangle()
                            .fill(Color.white)
                            .frame(height: 2)
                            .cornerRadius(1)
                    } else {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 2)
                    }
                }
            }
            
            // Tab 2: Komentar(99+)
            Button {
                selectedTab = 1
            } label: {
                HStack(spacing: 4) {
                    Text("Komentar(99+)")
                        .font(.system(size: 16, weight: selectedTab == 1 ? .bold : .regular))
                        .foregroundColor(selectedTab == 1 ? .white : Color(white: 0.6))
                    
                    Circle()
                        .fill(Color.red)
                        .frame(width: 6, height: 6)
                }
                .padding(.bottom, 6)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Recommendations Grid (Untukmu)
    private var recommendationsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 16) {
            recommendationCard(
                title: "Terikat Janji",
                cover: "https://pbcdnw.aoneroom.com/image/2026/09/17/aec7019b24d1e8faf17e7fd6e22a7658.jpg"
            )
            recommendationCard(
                title: "Bima Satria Garuda",
                cover: "https://pbcdnw.aoneroom.com/image/2026/09/17/6ef3affa71dfec768286dfa1cb7af784.jpg"
            )
            recommendationCard(
                title: "Mahligai untuk Cinta",
                cover: "https://pbcdnw.aoneroom.com/image/2026/09/25/bdf2a527ad8e31f576fb3ae47583d04d.jpg"
            )
            recommendationCard(
                title: "Dendam Sampai Mati",
                cover: "https://pbcdnw.aoneroom.com/image/2026/09/03/b201db9832b0d0c3fe7b735f50cc99a1.jpeg"
            )
        }
    }
    
    private func recommendationCard(title: String, cover: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: URL(string: cover)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Color.gray.opacity(0.3)
                }
            }
            .frame(height: 180)
            .clipped()
            .cornerRadius(10)
            
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
        }
    }
    
    // MARK: - Comments Section (Komentar)
    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(comments, id: \.0) { comment in
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(Color(red: 0.2, green: 0.5, blue: 0.4))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Text(String(comment.0.prefix(1)))
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(comment.0)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                            Text(comment.1)
                                .font(.system(size: 11))
                                .foregroundColor(Color(white: 0.5))
                        }
                        
                        Text(comment.2)
                            .font(.system(size: 13))
                            .foregroundColor(Color(white: 0.85))
                            .lineSpacing(2)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "hand.thumbsup")
                                .font(.system(size: 11))
                            Text("\(comment.3)")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(Color(white: 0.5))
                        .padding(.top, 2)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    // MARK: - Floating Download Button
    private var floatingDownloadButton: some View {
        Button {
            showDownloadSheet = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "bag.fill")
                    .font(.system(size: 16))
                Text("Unduh")
                    .font(.system(size: 16, weight: .bold))
            }
            .padding(.horizontal, 36)
            .padding(.vertical, 14)
            .background(Color(red: 0.94, green: 0.83, blue: 0.58))
            .foregroundColor(Color(red: 0.25, green: 0.18, blue: 0.05))
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.4), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Download Bottom Sheet
    private var downloadBottomSheet: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Unduh Video Offline")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Button {
                    showDownloadSheet = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title3)
                }
            }
            .padding(.top, 16)
            
            Text("Pilih Kualitas:")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack(spacing: 12) {
                ForEach(["1080P FHD (VIP)", "720P HD", "480P SD"], id: \.self) { res in
                    Button {
                        selectedResolution = res
                    } label: {
                        Text(res)
                            .font(.system(size: 13, weight: .semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedResolution == res ? Color(red: 0.0, green: 0.82, blue: 0.53) : Color(white: 0.18))
                            .foregroundColor(selectedResolution == res ? .black : .white)
                            .cornerRadius(8)
                    }
                }
            }
            
            Text("Pilih Part / Episode:")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(movie.episodes) { ep in
                        Button {
                            showDownloadSheet = false
                            withAnimation {
                                showDownloadToast = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                withAnimation {
                                    showDownloadToast = false
                                }
                            }
                        } label: {
                            Text(ep.title)
                                .font(.system(size: 14, weight: .bold))
                                .frame(width: 50, height: 40)
                                .background(Color(white: 0.2))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.1, green: 0.1, blue: 0.12).ignoresSafeArea())
        .presentationDetents([.fraction(0.45)])
    }
    
    // MARK: - Helpers
    private func setupInitialEpisode() {
        if let firstEp = movie.episodes.first {
            playEpisode(firstEp)
        } else {
            let defaultEp = Episode(number: 1, streamUrl: movie.defaultStreamUrl)
            playEpisode(defaultEp)
        }
    }
    
    private func playEpisode(_ ep: Episode) {
        selectedEpisode = ep
        if let url = URL(string: ep.streamUrl) {
            let newPlayer = AVPlayer(url: url)
            self.player = newPlayer
            newPlayer.play()
        }
    }
}
