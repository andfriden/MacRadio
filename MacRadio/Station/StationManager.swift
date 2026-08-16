//
//  StationManager.swift
//  MacRadio
//

import Foundation
import Combine


final class StationManager: ObservableObject {


    @Published var stations: [RadioStation] = []

    @Published var currentIndex: Int = 0

    @Published var hasSelectedStation: Bool = false


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

        guard hasSelectedStation else {

            return nil

        }


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

        hasSelectedStation = true

        saveLastStation()

    }



    func nextStation() -> RadioStation? {

        guard !stations.isEmpty else {

            return nil

        }


        if !hasSelectedStation {

            currentIndex = 0

        } else {

            currentIndex += 1


            if currentIndex >= stations.count {

                currentIndex = 0

            }

        }


        hasSelectedStation = true

        saveLastStation()


        return currentStation

    }



    func previousStation() -> RadioStation? {

        guard !stations.isEmpty else {

            return nil

        }


        if !hasSelectedStation {

            currentIndex = stations.count - 1

        } else {

            currentIndex -= 1


            if currentIndex < 0 {

                currentIndex = stations.count - 1

            }

        }


        hasSelectedStation = true

        saveLastStation()


        return currentStation

    }



    private func saveLastStation() {

        guard let station = currentStation else {

            return

        }


        settings.lastStationID =
            station.id.uuidString

    }



    private func restoreLastStation() {

        let savedID =
            settings.lastStationID


        guard !savedID.isEmpty else {

            hasSelectedStation = false

            return

        }



        guard let index = stations.firstIndex(where: {

            $0.id.uuidString == savedID

        }) else {

            hasSelectedStation = false

            return

        }


        currentIndex = index

        hasSelectedStation = true

    }
  
    func toggleFavorite(
        _ station: RadioStation
    ) {

        guard let index = stations.firstIndex(
            where: {
                $0.id == station.id
            }
        ) else {
            return
        }


        stations[index].isFavorite.toggle()
    }
    
}
