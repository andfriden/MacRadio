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


    var player: AVPlayer?

    var playerItem: AVPlayerItem?


    let settings: AppSettings

    let metadataService: MetadataService


    var cancellables = Set<AnyCancellable>()

    var playerCancellables = Set<AnyCancellable>()


    var reconnectTask: Task<Void, Never>?

    var stallTask: Task<Void, Never>?


    var reconnectAttempts = 0


    let maxReconnectAttempts = 3

    let reconnectDelayNanoseconds: UInt64 = 2_000_000_000

    let stallTimeoutNanoseconds: UInt64 = 3_000_000_000


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
}
