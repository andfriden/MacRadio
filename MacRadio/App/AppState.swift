//
//  AppState.swift
//  MacRadio
//

import Foundation
import Combine


final class AppState: ObservableObject {

    @Published var settings: AppSettings

    @Published var player: RadioPlayer

    @Published var stationManager: StationManager

    @Published var artworkService: ArtworkService


    let mediaCommandService: MediaCommandService


    private var cancellables = Set<AnyCancellable>()


    init() {

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


        self.settings =
            settings

        self.artworkService =
            artworkService

        self.stationManager =
            stationManager

        self.player =
            player


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


                    player.play(
                        station: station
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


                    player.play(
                        station: station
                    )
                }
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
    }
}
