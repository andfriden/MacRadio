//
//  RadioPlayer+Playback.swift
//  MacRadio
//

import Foundation
import AVFoundation


extension RadioPlayer {

    // MARK: - Playback


    func play(
        station: RadioStation
    ) {

        cancelReconnect()

        cancelStallDetection()

        reconnectAttempts = 0


        resetPlayerObservers()

        player?.pause()

        player = nil

        playerItem = nil


        metadataService.stop()


        currentStation = station

        currentTrack = nil

        state = .connecting


        let item = AVPlayerItem(
            url: station.streamURL
        )


        playerItem = item


        let newPlayer = AVPlayer(
            playerItem: item
        )


        player = newPlayer


        observe(
            player: newPlayer,
            item: item
        )


        applyVolume()


        metadataService.start(
            url: station.streamURL
        )


        newPlayer.play()


        print(
            "PLAY:",
            station.name
        )
    }


    func retry() {

        guard let station = currentStation else {

            state = .stopped

            return
        }


        play(
            station: station
        )
    }


    func toggle() {

        switch state {

        case .playing:

            pause()


        case .paused:

            resume()


        case .failed:

            retry()


        default:

            if let station = currentStation {

                play(
                    station: station
                )
            }
        }
    }


    func pause() {

        guard player != nil else {

            return
        }


        cancelReconnect()

        cancelStallDetection()

        player?.pause()

        state = .paused
    }


    func resume() {

        guard let player else {

            return
        }


        reconnectAttempts = 0

        cancelStallDetection()

        applyVolume()

        player.play()
    }


    func stop() {

        cancelReconnect()

        cancelStallDetection()

        reconnectAttempts = 0


        resetPlayerObservers()

        player?.pause()

        player = nil

        playerItem = nil


        metadataService.stop()


        currentStation = nil

        currentTrack = nil


        state = .stopped
    }


    func clearError() {

        cancelReconnect()

        cancelStallDetection()

        reconnectAttempts = 0


        if currentStation != nil {

            state = .connecting

        } else {

            state = .stopped
        }
    }
}
