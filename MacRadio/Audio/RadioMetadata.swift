//
//  RadioMetadat.swift
//  MacRadio
//
//  Created by Андерс Фриден on 15.08.2026.
//

import Foundation
import Combine


final class RadioMetadata: ObservableObject {


    @Published var artist: String = ""

    @Published var title: String = ""



    func update(
        from streamTitle: String
    ) {


        let parts = streamTitle
            .split(
                separator: "-"
            )
            .map {

                $0.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            }



        if parts.count >= 2 {


            artist = String(parts[0])

            title = String(parts[1])


        } else {


            title = streamTitle

        }

    }



    func clear() {


        artist = ""

        title = ""

    }

}
