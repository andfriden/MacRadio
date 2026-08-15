import Foundation
import Combine
import AVFoundation


final class RadioPlayer: ObservableObject {


    @Published var state: PlayerState = .stopped

    @Published var currentStation: RadioStation?
    
    @Published var currentTrack: Track?
    
    var currentArtist: String {
        currentTrack?.artist ?? ""
    }


    private var player: AVPlayer?
    
   
    func play(
        station: RadioStation
    ) {

        currentStation = station
        
        currentTrack = nil
        
        state = .connecting


        let item = AVPlayerItem(
            url: station.streamURL
        )


        player = AVPlayer(
            playerItem: item
        )


        player?.play()
        
        metadataService.start(
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
        
        metadataService.stop()

        currentStation = nil

        currentTrack = nil
        
        state = .stopped
    }



    func clearError() {

        state = .stopped
    }
    
    private let metadataService = MetadataService()


    init() {

        metadataService.$currentTrack
            .receive(on: DispatchQueue.main)
            .assign(
                to: &$currentTrack
            )

    }

}
