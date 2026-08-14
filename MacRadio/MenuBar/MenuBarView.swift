
import SwiftUI


struct MenuBarView: View {

    @EnvironmentObject var player: RadioPlayer

    private let loader = StationLoader()

    @State private var stations: [RadioStation] = []


    var body: some View {

        VStack(spacing: 12) {

            Image(systemName: "dot.radiowaves.left.and.right")
                .font(.system(size: 28))


            Text("MacRadio")
                .font(.headline)


            Divider()


            if let station = player.currentStation {

                VStack {

                    Text(station.name)
                        .font(.headline)

                    Text(player.isPlaying ? "Playing" : "Paused")
                        .foregroundStyle(.secondary)

                }

            } else {

                Text("No station selected")
                    .foregroundStyle(.secondary)

            }


            Divider()


            ForEach(stations) { station in

                Button {

                    player.play(
                        station: station
                    )

                } label: {

                    HStack {

                        Image(systemName: "radio")

                        Text(station.name)

                    }

                }
            }


            Divider()


            HStack {

                Button {

                    player.pause()

                } label: {

                    Image(systemName: "pause.fill")

                }


                Button {

                    if let station = player.currentStation {

                        player.play(
                            station: station
                        )

                    }

                } label: {

                    Image(systemName: "play.fill")

                }

            }
            .buttonStyle(.borderless)


            Divider()


            Button("Quit") {

                NSApplication.shared.terminate(nil)

            }

        }
        .padding()
        .frame(width: 280)
        .onAppear {

            stations = loader.load()

        }

    }
}
