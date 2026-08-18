//
//  AppState.swift
//  MacRadio
//

import Foundation
import Combine


final class AppState: ObservableObject {

    static let shared = AppState()


    // MARK: - Published State

    @Published var settings: AppSettings
    @Published var player: RadioPlayer
    @Published var stationManager: StationManager
    @Published var artworkService: ArtworkService


    // MARK: - Services

    let mediaCommandService: MediaCommandService
    let notificationService: NotificationService


    // MARK: - Cancellables

    private var cancellables = Set<AnyCancellable>()


    // MARK: - Init

    private init() {

        let settings =
            AppSettings()

        let artworkService =
            ArtworkService()

        let stationManager =
            StationManager(
                settings: settings
            )

        let player =
            RadioPlayer(
                settings: settings,
                artworkService: artworkService
            )

        self.settings = settings
        self.artworkService = artworkService
        self.stationManager = stationManager
        self.player = player


        self.mediaCommandService =
            MediaCommandService(
                player: player,
                artworkService: artworkService,
                nextStation: {
                    [weak player, weak stationManager] in

                    guard
                        let player,
                        let stationManager,
                        let station =
                            stationManager.nextStation()
                    else {
                        return
                    }

                    AppState.play(
                        station,
                        with: player
                    )
                },
                previousStation: {
                    [weak player, weak stationManager] in

                    guard
                        let player,
                        let stationManager,
                        let station =
                            stationManager.previousStation()
                    else {
                        return
                    }

                    AppState.play(
                        station,
                        with: player
                    )
                }
            )


        self.notificationService =
            NotificationService(
                player: player,
                settings: settings
            )


        print(
            "Stations loaded:",
            stationManager.stations.count
        )


        player.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(
                in: &cancellables
            )


        stationManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(
                in: &cancellables
            )


        settings.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(
                in: &cancellables
            )


        if let station =
            stationManager.currentStation
        {
            player.currentStation =
                station
        }


        mediaCommandService.start()
        notificationService.start()
    }


    // MARK: - Station Playback

    func playStation(
        _ station: RadioStation
    ) {

        stationManager.select(
            station
        )

        player.play(
            station: station
        )
    }


    // MARK: - Shared Playback Helper

    private static func play(
        _ station: RadioStation,
        with player: RadioPlayer
    ) {

        player.play(
            station: station
        )
    }
}
