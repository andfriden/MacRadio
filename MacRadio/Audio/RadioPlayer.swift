import Foundation
import AVFoundation
import Combine


final class RadioPlayer: ObservableObject {


    private let bufferManager = BufferManager()


    @Published var state: PlayerState = .idle

    @Published var isPlaying = false

    @Published var currentStation: RadioStation?

    @Published var volume: Double = 1.0 {
        didSet {
            player?.volume = Float(volume)
        }
    }



    private var player: AVPlayer?

    private var bufferObserver: AnyCancellable?

    private var itemObserver: NSKeyValueObservation?



    func play(station: RadioStation) {


        print("Starting:", station.name)

        print(
            "Trying URL:",
            station.streamURL.absoluteString
        )


        stop()



        currentStation = station

        state = .connecting



        let item = AVPlayerItem(
            url: station.streamURL
        )


        item.preferredForwardBufferDuration = 30



        bufferManager.observe(
            item: item
        )


        observeBuffer()



        let avPlayer = AVPlayer(
            playerItem: item
        )


        avPlayer.volume = Float(volume)

        avPlayer.automaticallyWaitsToMinimizeStalling = true



        player = avPlayer



        observeItem(
            item
        )



        avPlayer.play()

    }




    func pause() {


        player?.pause()

        isPlaying = false

        state = .paused

    }




    func stop() {


        player?.pause()


        player = nil


        currentStation = nil


        isPlaying = false

        state = .idle


        itemObserver?.invalidate()

        itemObserver = nil


        bufferObserver?.cancel()

        bufferObserver = nil


        bufferManager.reset()

    }




    func resume() {


        guard let player else {
            return
        }


        player.play()

    }





    private func observeItem(
        _ item: AVPlayerItem
    ) {


        itemObserver = item.observe(
            \.status,
            options: [.new]
        ) { [weak self] item, _ in


            DispatchQueue.main.async {


                guard let self else {
                    return
                }



                switch item.status {


                case .readyToPlay:


                    self.state = .playing

                    self.isPlaying = true



                case .failed:


                    self.state = .error(
                        item.error?.localizedDescription
                        ?? "Unknown error"
                    )


                    self.isPlaying = false



                case .unknown:


                    self.state = .buffering



                @unknown default:

                    break

                }

            }

        }

    }







    private func observeBuffer() {


        bufferObserver = bufferManager.$state

            .receive(on: DispatchQueue.main)

            .sink { [weak self] bufferState in



                guard let self else {
                    return
                }



                switch bufferState {


                case .empty:

                    break



                case .buffering:

                    self.state = .buffering



                case .ready:

                    self.state = .playing

                    self.isPlaying = true



                case .stalled:

                    self.state = .error(
                        "Stream stalled"
                    )

                    self.isPlaying = false

                }

            }

    }


}
