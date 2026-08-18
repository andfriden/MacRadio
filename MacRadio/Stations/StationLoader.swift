//
//  StationLoader.swift
//  MacRadio
//

import Foundation
import AppKit


final class StationLoader {

    private let fileManager = FileManager.default

    private let applicationSupportDirectoryName = "MacRadio"
    private let stationsFileName = "stations.json"


    // MARK: - Public

    func load() -> [RadioStation] {

        if fileManager.fileExists(
            atPath: userStationsURL.path
        ) {
            return loadUserStations(
                from: userStationsURL
            )
        }

        return createUserStationsFromDefaults()
    }


    func resetToDefaults() -> [RadioStation] {

        guard let bundledStations = loadBundledStations() else {
            return []
        }

        let userStations = bundledStations.map(
            makeUserStation
        )

        do {

            try saveUserStations(
                userStations
            )

            return makeRadioStations(
                from: userStations
            )

        } catch {

            print(
                "Unable to reset stations:",
                error
            )

            return bundledStations
        }
    }


    func openStationsFile() {

        if !fileManager.fileExists(
            atPath: userStationsURL.path
        ) {
            _ = createUserStationsFromDefaults()
        }

        NSWorkspace.shared.open(
            userStationsURL
        )
    }


    // MARK: - User Stations

    private func loadUserStations(
        from url: URL
    ) -> [RadioStation] {

        do {

            let data = try Data(
                contentsOf: url
            )

            let decodedStations =
                try JSONDecoder().decode(
                    [UserStation].self,
                    from: data
                )

            var didNormalize = false

            let normalizedStations =
                decodedStations.map { station in

                    guard station.id == nil else {
                        return station
                    }

                    didNormalize = true

                    return UserStation(
                        id: UUID(),
                        name: station.name,
                        genre: station.genre,
                        streamURL: station.streamURL,
                        artworkURL: station.artworkURL,
                        country: station.country,
                        tags: station.tags
                    )
                }

            if didNormalize {

                try saveUserStations(
                    normalizedStations
                )
            }

            return makeRadioStations(
                from: normalizedStations
            )

        } catch {

            print(
                "User stations loading error:",
                error
            )

            return []
        }
    }


    private func saveUserStations(
        _ stations: [UserStation]
    ) throws {

        let data =
            try JSONEncoder.prettyPrinted.encode(
                stations
            )

        try fileManager.createDirectory(
            at: applicationSupportURL,
            withIntermediateDirectories: true
        )

        try data.write(
            to: userStationsURL,
            options: .atomic
        )
    }


    // MARK: - Defaults

    private func createUserStationsFromDefaults()
        -> [RadioStation]
    {

        guard let bundledStations =
            loadBundledStations()
        else {
            return []
        }

        let userStations =
            bundledStations.map(
                makeUserStation
            )

        do {

            try saveUserStations(
                userStations
            )

        } catch {

            print(
                "Unable to create user stations file:",
                error
            )
        }

        return makeRadioStations(
            from: userStations
        )
    }


    private func loadBundledStations()
        -> [RadioStation]?
    {

        guard let url = Bundle.main.url(
            forResource: "stations",
            withExtension: "json"
        ) else {

            print(
                "Bundled stations.json not found"
            )

            return nil
        }

        do {

            let data = try Data(
                contentsOf: url
            )

            return try JSONDecoder().decode(
                [RadioStation].self,
                from: data
            )

        } catch {

            print(
                "Bundled stations loading error:",
                error
            )

            return nil
        }
    }


    // MARK: - Conversion

    private func makeUserStation(
        from station: RadioStation
    ) -> UserStation {

        UserStation(
            id: station.id,
            name: station.name,
            genre: station.genre,
            streamURL: station.streamURL,
            artworkURL: station.artworkURL,
            country: station.country,
            tags: station.tags
        )
    }


    private func makeRadioStations(
        from stations: [UserStation]
    ) -> [RadioStation] {

        stations.map {
            $0.makeRadioStation()
        }
    }


    // MARK: - Paths

    private var applicationSupportURL: URL {

        guard let baseURL =
            fileManager.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first
        else {
            return URL(
                fileURLWithPath:
                    NSHomeDirectory()
            )
        }

        return baseURL.appendingPathComponent(
            applicationSupportDirectoryName,
            isDirectory: true
        )
    }


    private var userStationsURL: URL {

        applicationSupportURL.appendingPathComponent(
            stationsFileName
        )
    }
}


// MARK: - JSON Encoder

private extension JSONEncoder {

    static var prettyPrinted: JSONEncoder {

        let encoder = JSONEncoder()

        encoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys
        ]

        return encoder
    }
}
