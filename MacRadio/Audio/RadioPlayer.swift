import Foundation
import Combine
import AVFoundation


final class RadioPlayer: ObservableObject {


    @Published var state: PlayerState = .stopped

    @Published var currentStation: RadioStation?
    
    @Published var currentArtist: String = ""

    @Published var currentTrack: String = ""


    private var player: AVPlayer?
    
    private let metadataReader = ICYMetadataReader()



    func play(
        station: RadioStation
    ) {

        currentStation = station
        
        currentArtist = ""

        currentTrack = ""

        state = .connecting


        let item = AVPlayerItem(
            url: station.streamURL
        )


        player = AVPlayer(
            playerItem: item
        )


        player?.play()
        
        metadataReader.onMetadataUpdate = { [weak self] metadata in
                        
            let parser = RadioMetadata()

            parser.update(
                from: metadata
            )

            self?.currentArtist = parser.artist

            self?.currentTrack = parser.title

        }


        metadataReader.start(
            url: station.streamURL
        )

        print("PLAY:", station.name)
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
        
        metadataReader.stop()

        currentStation = nil

        currentArtist = ""

        currentTrack = ""

        state = .stopped
    }



    func clearError() {

        state = .stopped
    }

}
