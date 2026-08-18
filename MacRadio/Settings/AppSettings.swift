//
//  AppSettings.swift
//  MacRadio
//

import Foundation
import Combine


final class AppSettings: ObservableObject {

    // MARK: - Keys

    private enum Key {
        static let lastStationID = "lastStationID"
        static let recentStationIDs = "recentStationIDs"
        static let favoriteStationIDs = "favoriteStationIDs"
        static let volume = "volume"
        static let isMuted = "isMuted"
        static let notificationsEnabled = "notificationsEnabled"
    }


    // MARK: - Published Settings

    @Published var lastStationID: String {
        didSet {
            save(
                lastStationID,
                forKey: Key.lastStationID
            )
        }
    }

    @Published var recentStationIDs: [String] {
        didSet {
            save(
                recentStationIDs,
                forKey: Key.recentStationIDs
            )
        }
    }

    @Published var favoriteStationIDs: [String] {
        didSet {
            save(
                favoriteStationIDs,
                forKey: Key.favoriteStationIDs
            )
        }
    }

    @Published var volume: Double {
        didSet {
            save(
                volume,
                forKey: Key.volume
            )
        }
    }

    @Published var isMuted: Bool {
        didSet {
            save(
                isMuted,
                forKey: Key.isMuted
            )
        }
    }

    @Published var notificationsEnabled: Bool {
        didSet {
            save(
                notificationsEnabled,
                forKey: Key.notificationsEnabled
            )
        }
    }


    // MARK: - Init

    init(
        defaults: UserDefaults = .standard
    ) {

        self.defaults = defaults

        lastStationID =
            defaults.string(
                forKey: Key.lastStationID
            )
            ?? ""

        recentStationIDs =
            defaults.stringArray(
                forKey: Key.recentStationIDs
            )
            ?? []

        favoriteStationIDs =
            defaults.stringArray(
                forKey: Key.favoriteStationIDs
            )
            ?? []

        volume =
            defaults.object(
                forKey: Key.volume
            ) as? Double
            ?? 1.0

        isMuted =
            defaults.bool(
                forKey: Key.isMuted
            )

        notificationsEnabled =
            defaults.object(
                forKey: Key.notificationsEnabled
            ) == nil
            ? true
            : defaults.bool(
                forKey: Key.notificationsEnabled
            )
    }


    // MARK: - Private

    private let defaults: UserDefaults


    private func save<T>(
        _ value: T,
        forKey key: String
    ) {

        defaults.set(
            value,
            forKey: key
        )
    }
}
