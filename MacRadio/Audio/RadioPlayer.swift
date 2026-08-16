//
//  RadioPlayer.swift
//  MacRadio
//
//  Created by Андерс Фриден on 14.08.2026.
//

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


    var currentTitle: String {

        currentTrack?.title ?? ""
    }


    private var player: AVPlayer?

    private let settings: AppSettings

    private let metadataService: MetadataService

    private var cancellables = Set<AnyCancellable>()


    init(
        settings: AppSettings,
        artworkService: ArtworkService
    ) {

        self.settings = settings

        self.metadataService = MetadataService(
            artworkService: artworkService
        )


        metadataService.$currentTrack
            .receive(on: DispatchQueue.main)
            .assign(
                to: &$currentTrack
            )


        settings.$volume
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in

                self?.applyVolume()
            }
            .store(
                in: &cancellables
            )


        settings.$isMuted
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in

                self?.applyVolume()
            }
            .store(
                in: &cancellables
            )
    }


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


        applyVolume()


        player?.play()


        metadataService.start(
            url: station.streamURL
        )


        print(
            "PLAY:",
            station.name
        )


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

        applyVolume()

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


    // MARK: - Volume


    func setVolume(
        _ value: Double
    ) {

        settings.volume = value

        applyVolume()
    }


    func toggleMute() {

        settings.isMuted.toggle()

        applyVolume()
    }


    private func applyVolume() {

        guard let player else {

            return
        }


        if settings.isMuted {

            player.volume = 0

        } else {

            player.volume = Float(
                settings.volume
            )
        }
    }
}
