
import Foundation
import AVFoundation
import Combine


final class BufferManager: ObservableObject {


    enum BufferState {

        case empty
        case buffering
        case ready
        case stalled

    }


    @Published var state: BufferState = .empty


    private var observers: [NSKeyValueObservation] = []



    func observe(
        item: AVPlayerItem
    ) {


        observers.removeAll()



        let statusObserver = item.observe(
            \.status,
            options: [.new]
        ) { [weak self] item, _ in


            DispatchQueue.main.async {


                switch item.status {


                case .readyToPlay:

                    self?.state = .ready


                case .failed:

                    self?.state = .stalled


                default:

                    self?.state = .buffering

                }

            }

        }



        let emptyObserver = item.observe(
            \.isPlaybackBufferEmpty,
            options: [.new]
        ) { [weak self] item, _ in


            DispatchQueue.main.async {


                if item.isPlaybackBufferEmpty {

                    self?.state = .buffering

                }

            }

        }




        let keepUpObserver = item.observe(
            \.isPlaybackLikelyToKeepUp,
            options: [.new]
        ) { [weak self] item, _ in


            DispatchQueue.main.async {


                if item.isPlaybackLikelyToKeepUp {

                    self?.state = .ready

                }

            }

        }



        observers.append(statusObserver)
        observers.append(emptyObserver)
        observers.append(keepUpObserver)

    }




    func reset() {


        observers.forEach {

            $0.invalidate()

        }


        observers.removeAll()


        state = .empty

    }


}
