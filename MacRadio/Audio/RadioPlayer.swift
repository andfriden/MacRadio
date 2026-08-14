import Foundation
import AVFoundation
import Combine


final class RadioPlayer: ObservableObject {

    private var player: AVPlayer?


    @Published var isPlaying = false

    @Published var currentStation: RadioStation?


    func play(station: RadioStation) {

        print("Starting:", station.name)

        let item = AVPlayerItem(
            url: station.streamURL
        )


        player = AVPlayer(
            playerItem: item
        )


        player?.automaticallyWaitsToMinimizeStalling = true


        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemFailedToPlayToEndTime,
            object: item,
            queue: .main
        ) { notification in

            print(
                "Playback error:",
                notification.userInfo ?? [:]
            )

        }

        print(
            "Trying URL:",
            station.streamURL.absoluteString
        )
        player?.play()
        print(
            "Trying URL:",
            station.streamURL.absoluteString
        )

        currentStation = station

        isPlaying = true
    }



    func pause() {

        player?.pause()

        isPlaying = false

    }



    func stop() {

        player?.pause()

        player = nil

        currentStation = nil

        isPlaying = false

    }

}
