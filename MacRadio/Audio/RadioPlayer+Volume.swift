//
//  RadioPlayer+Volume.swift
//  MacRadio
//

import Foundation
import AVFoundation


extension RadioPlayer {

    // MARK: - Volume


    func setVolume(
        _ value: Double
    ) {

        settings.volume = value

        applyVolume()
    }


    func toggleMute() {

        settings.isMuted.toggle()

        applyVolume()
    }


    func applyVolume() {

        guard let player else {

            return
        }


        if settings.isMuted {

            player.volume = 0

        } else {

            player.volume = Float(
                settings.volume
            )
        }
    }
}
