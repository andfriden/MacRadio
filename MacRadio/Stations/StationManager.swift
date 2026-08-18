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


    // MARK: - Loading

    func load() {

        stations = loader.load()

        restoreFavorites()
        restoreLastStation()
    }


    func reload() {

        stations = loader.load()

        restoreFavorites()

        guard
            let currentStationID = currentStation?.id,
            let index = stations.firstIndex(
                where: { $0.id == currentStationID }
            )
        else {
            currentIndex = 0
            hasSelectedStation = false
            return
        }

        currentIndex = index
        hasSelectedStation = true
    }


    func resetToDefaults() {

        stations = loader.resetToDefaults()

        restoreFavorites()
        restoreLastStation()
    }


    func openStationsFile() {

        loader.openStationsFile()
    }


    // MARK: - Current Station

    var currentStation: RadioStation? {

        guard hasSelectedStation else {
            return nil
        }

        guard stations.indices.contains(currentIndex) else {
            return nil
        }

        return stations[currentIndex]
    }


    var recentStations: [RadioStation] {

        settings.recentStationIDs.compactMap { id in

            stations.first { station in
                station.id.uuidString == id
            }
        }
    }


    // MARK: - Selection

    func select(
        _ station: RadioStation
    ) {

        guard
            let index = stations.firstIndex(
                where: {
                    $0.id == station.id
                }
            )
        else {
            return
        }

        currentIndex = index
        hasSelectedStation = true

        saveLastStation()
        recordRecentStation(
            station
        )
    }


    // MARK: - Next / Previous

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

        guard let station = currentStation else {
            return nil
        }

        saveLastStation()
        recordRecentStation(
            station
        )

        return station
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

        guard let station = currentStation else {
            return nil
        }

        saveLastStation()
        recordRecentStation(
            station
        )

        return station
    }


    // MARK: - Recent Stations

    func recordRecentStation(
        _ station: RadioStation
    ) {

        let stationID = station.id.uuidString

        var recent = settings.recentStationIDs

        recent.removeAll { id in
            id == stationID
        }

        recent.insert(
            stationID,
            at: 0
        )

        if recent.count > 3 {
            recent = Array(
                recent.prefix(3)
            )
        }

        settings.recentStationIDs = recent
    }


    // MARK: - Favorites

    func toggleFavorite(
        _ station: RadioStation
    ) {

        guard
            let index = stations.firstIndex(
                where: {
                    $0.id == station.id
                }
            )
        else {
            return
        }

        stations[index].isFavorite.toggle()

        saveFavorites()
    }


    var favoriteStations: [RadioStation] {

        stations.filter {
            $0.isFavorite
        }
    }


    private func restoreFavorites() {

        let favorites = Set(
            settings.favoriteStationIDs
        )

        for index in stations.indices {

            stations[index].isFavorite =
                favorites.contains(
                    stations[index]
                        .id
                        .uuidString
                )
        }
    }


    private func saveFavorites() {

        settings.favoriteStationIDs =
            stations
                .filter {
                    $0.isFavorite
                }
                .map {
                    $0.id.uuidString
                }
    }


    // MARK: - Persistence

    private func saveLastStation() {

        guard let station = currentStation else {
            return
        }

        settings.lastStationID =
            station.id.uuidString
    }


    private func restoreLastStation() {

        let savedID = settings.lastStationID

        guard !savedID.isEmpty else {
            hasSelectedStation = false
            return
        }

        guard
            let index = stations.firstIndex(
                where: {
                    $0.id.uuidString == savedID
                }
            )
        else {
            hasSelectedStation = false
            return
        }

        currentIndex = index
        hasSelectedStation = true
    }
}
