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


    @Published var stationManager = StationManager()



    init() {

        if let station = stationManager.currentStation {

            player.currentStation = station

        }

    }

}
