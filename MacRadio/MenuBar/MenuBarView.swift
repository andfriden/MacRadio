//
//  MenuBarView.swift
//  MacRadio
//

import SwiftUI


struct MenuBarView: View {


    @EnvironmentObject var appState: AppState



    var body: some View {

        VStack(spacing: 12) {


            header


            Divider()


            playerStatus


            Divider()


            playbackControls


            Divider()


            volumeControls


            Divider()


            stationsList


            Divider()


            quitButton

        }
        .padding(12)
        .frame(width: 320)

    }



    private var header: some View {

        VStack(spacing: 6) {


            Image(
                systemName: "dot.radiowaves.left.and.right"
            )
            .font(.system(size: 28))
            .foregroundStyle(.primary)



            Text("MacRadio")
                .font(.title3)
                .fontWeight(.bold)

        }

    }




    @ViewBuilder
    private var playerStatus: some View {


        switch appState.player.state {


        case .playing:


            HStack(spacing: 6) {


                Image(
                    systemName: "play.fill"
                )
                .font(.system(size: 12))


                MarqueeText(
                    text: currentTrackText
                )

            }
            .frame(height: 18)



        case .paused:


            Text(
                "⏸ \(currentStationName)"
            )
            .lineLimit(1)



        case .connecting:


            Text(
                "🔵 Connecting..."
            )



        case .stopped:


            Text(
                "⏹ Stopped"
            )

        }

    }






    private var playbackControls: some View {


        HStack(spacing: 26) {


            Button {


                previousStation()


            } label: {


                Image(
                    systemName: "backward.fill"
                )

            }




            Button {


                appState.player.toggle()


            } label: {


                Image(
                    systemName: playPauseIcon
                )

            }





            Button {


                nextStation()


            } label: {


                Image(
                    systemName: "forward.fill"
                )

            }


        }
        .font(.title3)

    }






    private var volumeControls: some View {


        HStack(spacing: 10) {


            Button {


                appState.player.toggleMute()


            } label: {


                Image(
                    systemName:
                        appState.settings.isMuted
                        ? "speaker.slash.fill"
                        : "speaker.wave.2.fill"
                )

            }
            .buttonStyle(.plain)




            Slider(
                value: $appState.settings.volume,
                in: 0...1
            )




            Image(
                systemName: "speaker.wave.3.fill"
            )
            .font(.system(size: 12))

        }

    }







    private var stationsList: some View {


        VStack(alignment: .leading, spacing: 6) {


            Text("Stations")
                .font(.headline)



            ScrollView {


                VStack(spacing: 4) {


                    ForEach(
                        appState.stationManager.stations
                    ) { station in



                        Button {


                            appState.stationManager.select(
                                station
                            )


                            appState.player.play(
                                station: station
                            )



                        } label: {


                            HStack {


                                Image(
                                    systemName:
                                        isCurrent(station)
                                        ? "checkmark.circle.fill"
                                        : "radio"
                                )



                                Text(
                                    station.name
                                )
                                .lineLimit(1)



                                Spacer()


                            }

                        }
                        .buttonStyle(.plain)


                    }


                }


            }
            .frame(
                maxHeight: 180
            )

        }

    }






    private var quitButton: some View {


        Button {


            NSApplication.shared.terminate(nil)


        } label: {


            Label(
                "Quit MacRadio",
                systemImage: "xmark.circle"
            )

        }

    }







    private var currentStationName: String {


        appState.player.currentStation?.name
        ?? "MacRadio"

    }






    private var currentTrackText: String {


        let artist =
        appState.player.currentArtist


        let title =
        appState.player.currentTitle



        if !artist.isEmpty &&
            !title.isEmpty {


            return "\(artist) — \(title)"

        }



        return currentStationName

    }






    private var playPauseIcon: String {


        switch appState.player.state {


        case .playing:

            return "pause.fill"



        default:

            return "play.fill"

        }

    }






    private func isCurrent(
        _ station: RadioStation
    ) -> Bool {


        appState.player.currentStation?.id ==
        station.id

    }






    private func nextStation() {


        if let station =
            appState.stationManager.nextStation()
        {


            appState.player.play(
                station: station
            )

        }

    }






    private func previousStation() {


        if let station =
            appState.stationManager.previousStation()
        {


            appState.player.play(
                station: station
            )

        }

    }


}
