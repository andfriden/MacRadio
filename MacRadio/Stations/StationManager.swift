//
//  StationManager.swift
//  MacRadio
//

import Foundation
import Combine


final class StationManager: ObservableObject {

    @Published var stations: [RadioStation] = []
    @Published var currentIndex = 0
    @Published var hasSelectedStation = false

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

        let currentStationID =
            currentStation?.id

        stations = loader.load()

        restoreFavorites()

        guard let currentStationID,
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

         
    // MARK: - User Stations

    func addStation(
        name: String,
        streamURL: URL,
        artworkURL: URL?
    ) throws {

        let station = UserStation(
            id: UUID(),
            name: name,
            genre: nil,
            streamURL: streamURL,
            artworkURL: artworkURL,
            country: nil,
            tags: nil
        )

        try loader.addUserStation(
            station
        )

        stations = loader.load()
        restoreFavorites()
    }


    

    // MARK: - Current Station

    var currentStation: RadioStation? {

        guard hasSelectedStation,
              stations.indices.contains(currentIndex)
        else {
            return nil
        }

        return stations[currentIndex]
    }


    var recentStations: [RadioStation] {

        settings.recentStationIDs.compactMap { id in
            stations.first {
                $0.id.uuidString == id
            }
        }
    }


    // MARK: - Selection

    func select(
        _ station: RadioStation
    ) {

        guard let index = index(
            of: station
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

        selectRelativeStation(
            offset: 1
        )
    }


    func previousStation() -> RadioStation? {

        selectRelativeStation(
            offset: -1
        )
    }


    private func selectRelativeStation(
        offset: Int
    ) -> RadioStation? {

        guard !stations.isEmpty else {
            return nil
        }

        if hasSelectedStation {

            currentIndex =
                wrappedIndex(
                    currentIndex + offset
                )

        } else {

            currentIndex =
                offset > 0
                ? 0
                : stations.count - 1
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


    private func wrappedIndex(
        _ index: Int
    ) -> Int {

        let count = stations.count

        guard count > 0 else {
            return 0
        }

        return (index % count + count) % count
    }


    // MARK: - Recent Stations

    func recordRecentStation(
        _ station: RadioStation
    ) {

        let stationID =
            station.id.uuidString

        var recent =
            settings.recentStationIDs

        recent.removeAll { id in
            id == stationID
        }

        recent.insert(
            stationID,
            at: 0
        )

        settings.recentStationIDs =
            Array(
                recent.prefix(3)
            )
    }


    // MARK: - Favorites

    func toggleFavorite(
        _ station: RadioStation
    ) {

        guard let index = index(
            of: station
        )
        else {
            return
        }

        stations[index].isFavorite.toggle()

        saveFavorites()
    }


    var favoriteStations: [RadioStation] {

        stations.filter(
            \.isFavorite
        )
    }


    private func restoreFavorites() {

        let favoriteIDs =
            Set(
                settings.favoriteStationIDs
            )

        for index in stations.indices {

            stations[index].isFavorite =
                favoriteIDs.contains(
                    stations[index]
                        .id
                        .uuidString
                )
        }
    }


    private func saveFavorites() {

        settings.favoriteStationIDs =
            stations
                .filter(\.isFavorite)
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

        let savedID =
            settings.lastStationID

        guard !savedID.isEmpty,
              let index = stations.firstIndex(
                where: {
                    $0.id.uuidString == savedID
                }
              )
        else {
            currentIndex = 0
            hasSelectedStation = false
            return
        }

        currentIndex = index
        hasSelectedStation = true
    }


    // MARK: - Helpers

    private func index(
        of station: RadioStation
    ) -> Int? {

        stations.firstIndex {
            $0.id == station.id
        }
    }
}
