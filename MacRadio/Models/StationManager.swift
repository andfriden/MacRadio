//
//  StationManager.swift
//  MacRadio
//
//  Created by Андерс Фриден on 15.08.2026.
//

import Foundation
import Combine


final class StationManager: ObservableObject {


    @Published var stations: [RadioStation] = []

    @Published var currentIndex: Int = 0



    private let loader = StationLoader()

    private let lastStationKey = "lastStationID"



    init() {
       
        load()

    }



    func load() {

        stations = loader.load()
        
        restoreLastStation()

    }



    var currentStation: RadioStation? {


        guard stations.indices.contains(currentIndex) else {

            return nil

        }


        return stations[currentIndex]

    }



    func select(_ station: RadioStation) {


        guard let index = stations.firstIndex(where: {
            $0.id == station.id
        }) else {

            return

        }


        currentIndex = index


        saveLastStation()

    }




    func nextStation() -> RadioStation? {


        guard !stations.isEmpty else {

            return nil

        }


        currentIndex += 1


        if currentIndex >= stations.count {

            currentIndex = 0

        }


        saveLastStation()


        return currentStation

    }





    private func saveLastStation() {


        guard let station = currentStation else {

            return

        }


        UserDefaults.standard.set(
            station.id.uuidString,
            forKey: lastStationKey
        )

    }





    private func restoreLastStation() {


        guard let savedID = UserDefaults.standard.string(
            forKey: lastStationKey
        )
        else {

            return

        }



        if let index = stations.firstIndex(where: {

            $0.id.uuidString == savedID

        }) {


            currentIndex = index


            print(
                "Restored station:",
                stations[index].name
            )

        }

    }
 
}
