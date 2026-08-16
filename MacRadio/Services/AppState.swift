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


        self.settings = settings



        self.player = RadioPlayer(
            settings: settings
        )



        self.stationManager = StationManager(
            settings: settings
        )



        self.artworkService = ArtworkService()



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



        stationManager.$currentIndex
            .receive(
                on: DispatchQueue.main
            )
            .sink { [weak self] _ in

                self?.updateArtwork()

            }
            .store(
                in: &cancellables
            )



        if let station =
            stationManager.currentStation {


            player.currentStation = station


            updateArtwork()

        }

    }





    private func updateArtwork() {


        guard let station =
                stationManager.currentStation
        else {

            artworkService.load(
                from: nil
            )

            return
        }



        artworkService.load(
            from: station.artworkURL
        )

    }


}
