//
//  StationManager.swift
//  MacRadio
//
//  Created by Андерс Фриден on 15.08.2026.
//

//
//  StationManager.swift
//  MacRadio
//

import Foundation
import Combine


final class StationManager: ObservableObject {


    @Published var stations: [RadioStation] = []


    @Published var currentIndex: Int = 0



    private let loader = StationLoader()


    private let settings: AppSettings



    init(
        settings: AppSettings
    ) {

        self.settings = settings

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



    func select(
        _ station: RadioStation
    ) {


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



    func previousStation() -> RadioStation? {


        guard !stations.isEmpty else {

            return nil

        }


        currentIndex -= 1


        if currentIndex < 0 {

            currentIndex = stations.count - 1

        }


        saveLastStation()


        return currentStation

    }



    private func saveLastStation() {


        guard let station = currentStation else {

            return

        }


        settings.lastStationID = station.id.uuidString

    }



    private func restoreLastStation() {


        let savedID = settings.lastStationID


        guard !savedID.isEmpty else {

            return

        }



        if let index = stations.firstIndex(where: {

            $0.id.uuidString == savedID

        }) {


            currentIndex = index

        }

    }

}
