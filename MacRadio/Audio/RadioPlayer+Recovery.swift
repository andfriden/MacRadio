//
//  RadioPlayer+Recovery.swift
//  MacRadio
//

import Foundation
import AVFoundation
import Combine


extension RadioPlayer {

    // MARK: - AVPlayer Observation


    func observe(
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


    func handleItemStatus(
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


    func handleTimeControlStatus(
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


    func beginStallDetection() {

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


    func cancelStallDetection() {

        stallTask?.cancel()

        stallTask = nil
    }


    // MARK: - Reconnect


    func handlePlaybackFailure() {

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


    func reconnect(
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


    func cancelReconnect() {

        reconnectTask?.cancel()

        reconnectTask = nil
    }


    // MARK: - Observer Cleanup


    func resetPlayerObservers() {

        playerCancellables.removeAll()
    }
}
