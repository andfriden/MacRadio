//
//  AppState.swift
//  MacRadio
//
//  Created by Андерс Фриден on 14.08.2026.
//

import Foundation
import Combine


final class AppState: ObservableObject {


    @Published var player = RadioPlayer()

    @Published var settings: AppSettings

    @Published var stationManager: StationManager



    private var cancellables = Set<AnyCancellable>()



    init() {


        let settings = AppSettings()


        self.settings = settings


        self.stationManager = StationManager(
            settings: settings
        )



        player.objectWillChange
            .sink { [weak self] _ in

                self?.objectWillChange.send()

            }
            .store(
                in: &cancellables
            )


        if !settings.lastStationID.isEmpty {

            if let station = stationManager.currentStation {

                player.play(
                    station: station
                )

            }

        }

    }

}
