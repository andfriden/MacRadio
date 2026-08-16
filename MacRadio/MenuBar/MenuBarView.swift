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

            PlayerStatusView(
                player: appState.player
            )

            Divider()

            playbackControls

            Divider()

            volumeControls

            MenuBarFavoritesView()

            Divider()

            MenuBarStationListView()
            
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
            .font(
                .system(size: 28)
            )


            Text("MacRadio")
                .font(.title3)
                .fontWeight(.bold)
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
                .symbolRenderingMode(.hierarchical)
            }
            .buttonStyle(
                .plain
            )



            Slider(
                value: $appState.settings.volume,
                in: 0...1
            )
            .frame(
                width: 150
            )



            Text(
                "\(Int(appState.settings.volume * 100))%"
            )
            .font(.caption)
            .monospacedDigit()
            .frame(
                width: 35,
                alignment: .trailing
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



    private var playPauseIcon: String {

        switch appState.player.state {

        case .playing:

            return "pause.fill"

        default:

            return "play.fill"
        }
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
