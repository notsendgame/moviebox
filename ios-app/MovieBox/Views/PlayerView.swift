import SwiftUI
import AVKit

public struct PlayerView: View {
    let streamUrl: String
    @Environment(\.dismiss) private var dismiss
    @State private var player: AVPlayer?
    
    public init(streamUrl: String) {
        self.streamUrl = streamUrl
    }
    
    public var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()
            
            if let player = player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
            } else {
                ProgressView("Buffering stream...")
                    .foregroundColor(.white)
            }
            
            Button {
                player?.pause()
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white.opacity(0.8))
                    .padding()
            }
        }
        .onAppear {
            if let url = URL(string: streamUrl) {
                let avPlayer = AVPlayer(url: url)
                self.player = avPlayer
                avPlayer.play()
            }
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
}
