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

    private var playerItem: AVPlayerItem?

    private let settings: AppSettings

    private let metadataService: MetadataService

    private var cancellables = Set<AnyCancellable>()

    private var playerCancellables = Set<AnyCancellable>()


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


    // MARK: - Playback


    func play(
        station: RadioStation
    ) {

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

        guard player != nil else {

            return
        }


        player?.pause()

        state = .paused
    }


    func resume() {

        guard let player else {

            return
        }


        applyVolume()

        player.play()
    }


    func stop() {

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

        if currentStation != nil {

            state = .connecting

        } else {

            state = .stopped
        }
    }


    // MARK: - AVPlayer Observation


    private func observe(
        player: AVPlayer,
        item: AVPlayerItem
    ) {

        playerCancellables.removeAll()


        item.publisher(
            for: \.status,
            options: [.initial, .new]
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] status in

            self?.handleItemStatus(
                status
            )
        }
        .store(
            in: &playerCancellables
        )


        player.publisher(
            for: \.timeControlStatus,
            options: [.initial, .new]
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] status in

            self?.handleTimeControlStatus(
                status
            )
        }
        .store(
            in: &playerCancellables
        )
    }


    private func handleItemStatus(
        _ status: AVPlayerItem.Status
    ) {

        switch status {

        case .unknown:

            if state != .paused {

                state = .connecting
            }


        case .readyToPlay:

            if player?.timeControlStatus ==
                .waitingToPlayAtSpecifiedRate
            {

                state = .buffering
            }


        case .failed:

            if let error = playerItem?.error {

                print(
                    "PLAYER ERROR:",
                    error.localizedDescription
                )
            }


            state = .failed


        @unknown default:

            state = .failed
        }
    }


    private func handleTimeControlStatus(
        _ status: AVPlayer.TimeControlStatus
    ) {

        switch status {

        case .paused:

            guard state != .failed else {

                return
            }


            if player?.currentItem?.status ==
                .readyToPlay
            {

                if state != .connecting {

                    state = .paused
                }
            }


        case .waitingToPlayAtSpecifiedRate:

            guard state != .failed else {

                return
            }


            state = .buffering


        case .playing:

            guard player?.currentItem?.status ==
                .readyToPlay
            else {

                return
            }


            state = .playing


        @unknown default:

            break
        }
    }


    // MARK: - Observer Cleanup


    private func resetPlayerObservers() {

        playerCancellables.removeAll()
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
