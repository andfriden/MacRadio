import SwiftUI


struct MenuBarView: View {

    @EnvironmentObject var appState: AppState


    var body: some View {

        VStack(alignment: .leading, spacing: 8) {

            playerStatus


            Divider()


            Button {
                appState.player.toggle()
            } label: {

                controlButton
            }


            Button {

                appState.player.stop()

            } label: {

                Label(
                    "Стоп",
                    systemImage: "stop.fill"
                )
            }
        }
        .padding(8)
    }



    @ViewBuilder
    private var playerStatus: some View {

        switch appState.player.state {

        case .playing:

            Text(
                "▶ \(stationName)"
            )


        case .paused:

            Text(
                "⏸ \(stationName)"
            )


        default:

            Text(
                "⏹ Стоп"
            )
        }
    }



    @ViewBuilder
    private var controlButton: some View {

        switch appState.player.state {

        case .playing:

            Label(
                "Пауза",
                systemImage: "pause.fill"
            )


        case .paused:

            Label(
                "Продолжить",
                systemImage: "play.fill"
            )


        default:

            Label(
                "Играть",
                systemImage: "play.fill"
            )
        }
    }



    private var stationName: String {

        appState.player.currentStation?.name ?? "Стоп"
    }
}
