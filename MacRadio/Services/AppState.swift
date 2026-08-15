//
//  AppState.swift
//  MacRadio
//
//  Created by Андерс Фриден on 14.08.2026.
//

import Foundation
import Combine


final class AppState: ObservableObject {


    let player: RadioPlayer

    let stationManager: StationManager


    private var cancellables = Set<AnyCancellable>()



    init() {


        player = RadioPlayer()

        stationManager = StationManager()



        player.objectWillChange
            .sink { [weak self] _ in

                self?.objectWillChange.send()

            }
            .store(
                in: &cancellables
            )



        setupAutoNextStation()

    }



    private func setupAutoNextStation() {


        player.onStreamFailed = { [weak self] in


            DispatchQueue.main.async {


                guard let self else {
                    return
                }



                if let nextStation = self.stationManager.nextStation() {


                    self.player.play(
                        station: nextStation
                    )


                }

            }


        }

    }

}
