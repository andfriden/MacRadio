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

        let url = userStationsURL

        if fileManager.fileExists(
            atPath: url.path
        ) {
            return loadUserStations(
                from: url
            )
        }

        return createUserStationsFromDefaults()
    }


    func resetToDefaults() -> [RadioStation] {

        guard let defaultStations = loadBundledStations() else {
            return []
        }

        let userStations =
            makeUserStations(
                from: defaultStations
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

            return defaultStations
        }
    }


    func openStationsFile() {

        let url = userStationsURL

        if !fileManager.fileExists(
            atPath: url.path
        ) {
            _ = createUserStationsFromDefaults()
        }

        NSWorkspace.shared.open(
            url
        )
    }


    // MARK: - User Stations

    private func loadUserStations(
        from url: URL
    ) -> [RadioStation] {

        do {

            let data =
                try Data(
                    contentsOf: url
                )

            let decodedStations =
                try JSONDecoder().decode(
                    [UserStation].self,
                    from: data
                )

            var normalizedStations: [UserStation] = []

            normalizedStations.reserveCapacity(
                decodedStations.count
            )

            var didChangeFile = false

            for station in decodedStations {

                if station.id != nil {

                    normalizedStations.append(
                        station
                    )

                } else {

                    normalizedStations.append(
                        UserStation(
                            id: UUID(),
                            name: station.name,
                            genre: station.genre,
                            streamURL: station.streamURL,
                            artworkURL: station.artworkURL,
                            country: station.country,
                            tags: station.tags
                        )
                    )

                    didChangeFile = true
                }
            }

            if didChangeFile {

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

        guard let bundledStations = loadBundledStations() else {
            return []
        }

        let userStations =
            makeUserStations(
                from: bundledStations
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

            let data =
                try Data(
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


    // MARK: - Model Conversion

    private func makeUserStations(
        from stations: [RadioStation]
    ) -> [UserStation] {

        stations.map {
            UserStation(
                id: $0.id,
                name: $0.name,
                genre: $0.genre,
                streamURL: $0.streamURL,
                artworkURL: $0.artworkURL,
                country: $0.country,
                tags: $0.tags
            )
        }
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

        fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]
        .appendingPathComponent(
            applicationSupportDirectoryName,
            isDirectory: true
        )
    }


    private var userStationsURL: URL {

        applicationSupportURL
            .appendingPathComponent(
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
