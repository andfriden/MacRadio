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

    private var reconnectTask: Task<Void, Never>?

    private var stallTask: Task<Void, Never>?

    private var reconnectAttempts = 0


    private let maxReconnectAttempts = 3

    private let reconnectDelayNanoseconds: UInt64 = 2_000_000_000

    private let stallTimeoutNanoseconds: UInt64 = 3_000_000_000


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


    deinit {

        reconnectTask?.cancel()

        stallTask?.cancel()

        playerCancellables.removeAll()
    }


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

                beginStallDetection()
            }


        case .failed:

            if let error = playerItem?.error {

                print(
                    "PLAYER ERROR:",
                    error.localizedDescription
                )
            }


            handlePlaybackFailure()


        @unknown default:

            handlePlaybackFailure()
        }
    }


    private func handleTimeControlStatus(
        _ status: AVPlayer.TimeControlStatus
    ) {

        switch status {

        case .paused:

            guard state != .failed,
                  state != .reconnecting
            else {

                return
            }


            cancelStallDetection()


            if player?.currentItem?.status ==
                .readyToPlay
            {

                if state != .connecting {

                    state = .paused
                }
            }


        case .waitingToPlayAtSpecifiedRate:

            guard state != .failed,
                  state != .reconnecting
            else {

                return
            }


            state = .buffering

            beginStallDetection()


        case .playing:

            guard player?.currentItem?.status ==
                .readyToPlay
            else {

                return
            }


            cancelStallDetection()

            reconnectAttempts = 0

            state = .playing


        @unknown default:

            break
        }
    }


    // MARK: - Stall Detection


    private func beginStallDetection() {

        guard currentStation != nil else {

            return
        }


        guard state == .buffering else {

            return
        }


        cancelStallDetection()


        stallTask = Task { [weak self] in

            do {

                try await Task.sleep(
                    nanoseconds:
                        self?.stallTimeoutNanoseconds
                        ?? 3_000_000_000
                )

            } catch {

                return
            }


            guard !Task.isCancelled else {

                return
            }


            await MainActor.run {

                guard let self else {

                    return
                }


                guard self.state == .buffering else {

                    return
                }


                guard self.currentStation != nil else {

                    return
                }


                self.stallTask = nil

                print(
                    "PLAYER STALL:"
                )

                self.handlePlaybackFailure()
            }
        }
    }


    private func cancelStallDetection() {

        stallTask?.cancel()

        stallTask = nil
    }


    // MARK: - Reconnect


    private func handlePlaybackFailure() {

        cancelStallDetection()


        guard currentStation != nil else {

            state = .failed

            return
        }


        guard reconnectAttempts <
            maxReconnectAttempts
        else {

            reconnectTask = nil

            state = .failed

            print(
                "PLAYER RECONNECT FAILED:"
            )

            return
        }


        reconnectAttempts += 1

        let attempt = reconnectAttempts


        state = .reconnecting


        print(
            "PLAYER RECONNECT:",
            attempt,
            "/",
            maxReconnectAttempts
        )


        reconnectTask?.cancel()


        reconnectTask = Task { [weak self] in

            do {

                try await Task.sleep(
                    nanoseconds:
                        self?.reconnectDelayNanoseconds
                        ?? 2_000_000_000
                )

            } catch {

                return
            }


            guard !Task.isCancelled else {

                return
            }


            await MainActor.run {

                guard let self else {

                    return
                }


                guard self.state == .reconnecting else {

                    return
                }


                guard let station =
                    self.currentStation
                else {

                    return
                }


                self.reconnectTask = nil

                self.reconnect(
                    station: station
                )
            }
        }
    }


    private func reconnect(
        station: RadioStation
    ) {

        guard state == .reconnecting else {

            return
        }


        cancelStallDetection()

        resetPlayerObservers()

        player?.pause()

        player = nil

        playerItem = nil


        metadataService.stop()


        currentTrack = nil


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
    }


    private func cancelReconnect() {

        reconnectTask?.cancel()

        reconnectTask = nil
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
