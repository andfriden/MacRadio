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


    private var cancellables = Set<AnyCancellable>()


    init() {

        let settings = AppSettings()

        let artworkService = ArtworkService()


        self.settings = settings

        self.artworkService = artworkService


        self.player = RadioPlayer(
            settings: settings,
            artworkService: artworkService
        )


        self.stationManager = StationManager(
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
            stationManager.currentStation {

            player.currentStation = station
        }
    }
}
