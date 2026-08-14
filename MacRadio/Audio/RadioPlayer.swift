import Foundation
import AVFoundation
import Combine


final class RadioPlayer: ObservableObject {


    private var player: AVPlayer?


    private let bufferManager = BufferManager()


    private var bufferObserver: AnyCancellable?



    @Published var state: PlayerState = .idle


    @Published var currentStation: RadioStation?


    @Published var volume: Double = 1.0 {

        didSet {

            player?.volume = Float(volume)

        }

    }




    func play(station: RadioStation) {


        currentStation = station

        state = .connecting


        print("Starting:", station.name)



        let item = AVPlayerItem(
            url: station.streamURL
        )



        bufferManager.observe(
            item: item
        )



        bufferObserver = bufferManager.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bufferState in


                switch bufferState {


                case .buffering:

                    self?.state = .buffering


                case .ready:

                    self?.state = .playing


                case .stalled:

                    self?.state = .error(
                        "Stream stalled"
                    )

                }

            }




        player = AVPlayer(
            playerItem: item
        )


        player?.volume = Float(volume)


        player?.play()

    }




    func pause() {


        player?.pause()

        state = .paused

    }




    func resume() {


        player?.play()

        state = .playing

    }




    func stop() {


        player?.pause()

        player = nil


        state = .idle

    }

}
