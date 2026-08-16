//
//  AppState.swift
//  MacRadio
//
//  Created by Андерс Фриден on 14.08.2026.
//

import Foundation
import Combine


final class AppState: ObservableObject {


    @Published var settings: AppSettings

    @Published var player: RadioPlayer

    @Published var stationManager: StationManager



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



        if let station = stationManager.currentStation {


            player.currentStation = station


        }

    }

}
