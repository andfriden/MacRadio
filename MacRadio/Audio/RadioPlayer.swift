import Foundation
import Combine
import AVFoundation


final class RadioPlayer: ObservableObject {


    @Published var state: PlayerState = .stopped

    @Published var currentStation: RadioStation?


    private var player: AVPlayer?



    func play(
        station: RadioStation
    ) {

        currentStation = station

        state = .connecting


        let item = AVPlayerItem(
            url: station.url
        )


        player = AVPlayer(
            playerItem: item
        )


        player?.play()


        state = .playing
    }



    func toggle() {

        switch state {

        case .playing:

            pause()


        case .paused:

            resume()


        default:

            if let station = currentStation {

                play(
                    station: station
                )

            }
        }
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

        currentStation = nil

        state = .stopped
    }



    func clearError() {

        state = .stopped
    }
}
