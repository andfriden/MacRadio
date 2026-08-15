import Foundation


enum PlayerState: Equatable {


    case idle
    case connecting
    case buffering
    case playing
    case paused
    case error(String)

    var icon: String {

        switch self {

        case .idle:
            return "○"

        case .connecting:
            return "◌"

        case .buffering:
            return "◌"

        case .playing:
            return "●"

        case .paused:
            return "Ⅱ"

        case .error:
            return "!"

        }

    }

    var description: String {

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
