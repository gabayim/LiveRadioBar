import AVFoundation
import Combine

@MainActor
final class RadioPlayer: ObservableObject {
    @Published var currentStation: RadioStation?
    @Published var isPlaying = false
    @Published var isLoading = false

    private var player: AVPlayer?
    private var statusObserver: AnyCancellable?

    func play(station: RadioStation) {
        stop()
        currentStation = station
        isLoading = true

        let item = AVPlayerItem(url: station.url)
        player = AVPlayer(playerItem: item)

        statusObserver = item.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self else { return }
                switch status {
                case .readyToPlay:
                    self.isLoading = false
                    self.isPlaying = true
                case .failed:
                    self.isLoading = false
                    self.isPlaying = false
                default:
                    break
                }
            }

        player?.play()
    }

    func stop() {
        statusObserver?.cancel()
        statusObserver = nil
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
        isPlaying = false
        isLoading = false
        currentStation = nil
    }

    func toggle(station: RadioStation) {
        if currentStation == station && isPlaying {
            stop()
        } else {
            play(station: station)
        }
    }
}
