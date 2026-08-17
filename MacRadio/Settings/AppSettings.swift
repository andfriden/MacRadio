//
//  AppSettings.swift
//  MacRadio
//
//  Created by Андерс Фриден on 16.08.2026.
//

import Foundation
import Combine


final class AppSettings: ObservableObject {

    @Published var lastStationID: String {

        didSet {

            UserDefaults.standard.set(
                lastStationID,
                forKey: "lastStationID"
            )
        }
    }


    @Published var recentStationIDs: [String] {

        didSet {

            UserDefaults.standard.set(
                recentStationIDs,
                forKey: "recentStationIDs"
            )
        }
    }


    @Published var favoriteStationIDs: [String] {

        didSet {

            UserDefaults.standard.set(
                favoriteStationIDs,
                forKey: "favoriteStationIDs"
            )
        }
    }


    @Published var volume: Double {

        didSet {

            UserDefaults.standard.set(
                volume,
                forKey: "volume"
            )
        }
    }


    @Published var isMuted: Bool {

        didSet {

            UserDefaults.standard.set(
                isMuted,
                forKey: "isMuted"
            )
        }
    }


    @Published var notificationsEnabled: Bool {

        didSet {

            UserDefaults.standard.set(
                notificationsEnabled,
                forKey: "notificationsEnabled"
            )
        }
    }


    init() {

        lastStationID =
            UserDefaults.standard.string(
                forKey: "lastStationID"
            )
            ?? ""


        recentStationIDs =
            UserDefaults.standard.stringArray(
                forKey: "recentStationIDs"
            )
            ?? []


        favoriteStationIDs =
            UserDefaults.standard.stringArray(
                forKey: "favoriteStationIDs"
            )
            ?? []


        volume =
            UserDefaults.standard.object(
                forKey: "volume"
            ) as? Double
            ?? 1.0


        isMuted =
            UserDefaults.standard.bool(
                forKey: "isMuted"
            )


        if UserDefaults.standard.object(
            forKey: "notificationsEnabled"
        ) == nil {

            notificationsEnabled = true

        } else {

            notificationsEnabled =
                UserDefaults.standard.bool(
                    forKey: "notificationsEnabled"
                )
        }
    }
}
