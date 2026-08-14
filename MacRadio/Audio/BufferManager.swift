import Foundation
import AVFoundation
import Combine


final class BufferManager: ObservableObject {


    enum BufferState: Equatable {

        case empty
        case buffering
        case ready
        case stalled

    }


    @Published var state: BufferState = .empty


    private var observers: [NSKeyValueObservation] = []

    private var notificationObservers: [NSObjectProtocol] = []



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


                case .unknown:

                    self?.state = .buffering
                    print("Buffer: buffering")


                @unknown default:

                    break

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



        let stalledObserver = NotificationCenter.default.addObserver(
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


        notificationObservers.append(
            stalledObserver
        )

    }




    func reset() {


        observers.forEach { observer in

            observer.invalidate()

        }


        observers.removeAll()



        notificationObservers.forEach { observer in

            NotificationCenter.default.removeObserver(observer)

        }


        notificationObservers.removeAll()



        state = .empty

    }


}
