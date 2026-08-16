//
//  AppSettings.swift
//  MacRadio
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



    @Published var favoriteStationIDs: [String] {

        didSet {

            UserDefaults.standard.set(
                favoriteStationIDs,
                forKey: "favoriteStationIDs"
            )
        }
    }



    init() {


        lastStationID =
        UserDefaults.standard.string(
            forKey: "lastStationID"
        )
        ?? ""



        volume =
        UserDefaults.standard.object(
            forKey: "volume"
        ) as? Double
        ?? 1.0



        isMuted =
        UserDefaults.standard.bool(
            forKey: "isMuted"
        )



        favoriteStationIDs =
        UserDefaults.standard.stringArray(
            forKey: "favoriteStationIDs"
        )
        ?? []

    }
}
