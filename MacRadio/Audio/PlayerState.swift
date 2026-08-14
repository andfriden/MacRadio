//
//  PlayerState.swift
//  MacRadio
//
//  Created by Андерс Фриден on 14.08.2026.
//

import Foundation


enum PlayerState: Equatable {

    case idle

    case connecting

    case buffering

    case playing

    case paused

    case error(String)



    var title: String {

        switch self {

        case .idle:
            return "Idle"

        case .connecting:
            return "Connecting..."

        case .buffering:
            return "Buffering..."

        case .playing:
            return "Playing"

        case .paused:
            return "Paused"

        case .error(let message):
            return "Error: \(message)"

        }

    }

}
