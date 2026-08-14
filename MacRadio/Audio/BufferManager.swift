import Foundation
import AVFoundation
import Combine


final class BufferManager: ObservableObject {


    enum BufferState: Equatable {

        case buffering
        case ready
        case stalled

    }


    @Published var state: BufferState = .buffering



    private var observers: [NSKeyValueObservation] = []

    private var notifications: [NSObjectProtocol] = []



    func observe(item: AVPlayerItem) {


        reset()



        let statusObserver = item.observe(
            \.status,
            options: [.new]
        ) { [weak self] item, _ in


            DispatchQueue.main.async {


                switch item.status {


                case .readyToPlay:

                    self?.state = .ready

                    print("Buffer: ready")


                case .failed:

                    self?.state = .stalled

                    print("Buffer: stalled")


                default:

                    self?.state = .buffering

                    print("Buffer: buffering")

                }

            }

        }



        let emptyObserver = item.observe(
            \.isPlaybackBufferEmpty,
            options: [.new]
        ) { [weak self] item, _ in


            if item.isPlaybackBufferEmpty {

                DispatchQueue.main.async {

                    self?.state = .buffering

                    print("Buffer: buffering")

                }

            }

        }



        let keepUpObserver = item.observe(
            \.isPlaybackLikelyToKeepUp,
            options: [.new]
        ) { [weak self] item, _ in


            if item.isPlaybackLikelyToKeepUp {

                DispatchQueue.main.async {

                    self?.state = .ready

                    print("Buffer: ready")

                }

            }

        }



        let stalled = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemPlaybackStalled,
            object: item,
            queue: .main
        ) { [weak self] _ in


            self?.state = .stalled

            print("Buffer: stalled")

        }



        observers = [
            statusObserver,
            emptyObserver,
            keepUpObserver
        ]


        notifications.append(stalled)

    }




    func reset() {


        observers.forEach {
            $0.invalidate()
        }


        observers.removeAll()



        notifications.forEach {

            NotificationCenter.default.removeObserver($0)

        }


        notifications.removeAll()

    }

}
