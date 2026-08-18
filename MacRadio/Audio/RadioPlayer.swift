//
//  RadioPlayer.swift
//  MacRadio
//

import Foundation
import Combine
import AVFoundation


final class RadioPlayer: ObservableObject {

    // MARK: - Published State

    @Published var state: PlayerState = .stopped
    @Published var currentStation: RadioStation?
    @Published var currentTrack: Track?


    // MARK: - Current Metadata

    var currentArtist: String {
        currentTrack?.artist ?? ""
    }

    var currentTitle: String {
        currentTrack?.title ?? ""
    }


    // MARK: - AVPlayer

    var player: AVPlayer?
    var playerItem: AVPlayerItem?


    // MARK: - Services

    let settings: AppSettings
    let metadataService: MetadataService


    // MARK: - Cancellables

    var cancellables = Set<AnyCancellable>()
    var playerCancellables = Set<AnyCancellable>()


    // MARK: - Recovery

    var reconnectTask: Task<Void, Never>?
    var stallTask: Task<Void, Never>?

    var reconnectAttempts = 0

    let maxReconnectAttempts = 3

    let reconnectDelayNanoseconds: UInt64 =
        2_000_000_000

    let stallTimeoutNanoseconds: UInt64 =
        3_000_000_000


    // MARK: - Init

    init(
        settings: AppSettings,
        artworkService: ArtworkService
    ) {

        self.settings = settings

        self.metadataService =
            MetadataService(
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


    // MARK: - Deinit

    deinit {

        reconnectTask?.cancel()
        stallTask?.cancel()

        playerCancellables.removeAll()
    }
}
