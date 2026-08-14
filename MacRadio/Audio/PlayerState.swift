import Foundation


enum PlayerState: Equatable {


    case idle
    case connecting
    case buffering
    case playing
    case paused
    case error(String)



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
