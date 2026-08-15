import SwiftUI


struct MenuBarView: View {


    @EnvironmentObject var appState: AppState



    var body: some View {

        VStack(spacing: 12) {


            Image(systemName: "dot.radiowaves.left.and.right")
                .font(.system(size: 28))
                .foregroundStyle(.primary)



            Text("MacRadio")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.primary)



            Divider()



            if let station = appState.player.currentStation {


                VStack(spacing: 4) {


                    Label(
                        station.name,
                        systemImage: "radio"
                    )
                    .font(.subheadline)
                    .fontWeight(.semibold)



                    Label(
                        appState.player.state.description,
                        systemImage: "wave.3.right"
                    )
                    .font(.subheadline)
                    .fontWeight(.medium)


                }


            } else {


                Text("No station selected")
                    .foregroundStyle(.primary)


            }
                

            Divider()



            ForEach(appState.stationManager.stations) { station in


                Button {


                    appState.player.play(
                        station: station
                    )


                } label: {


                    HStack {


                        Image(systemName: "radio")
                            .foregroundStyle(.primary)



                        Text(station.name)
                            .foregroundStyle(.primary)


                    }


                }

            }
            .foregroundStyle(.primary)
            
            Divider()



            Button {


                NSApplication.shared.terminate(nil)


            } label: {


                HStack {

                    Image(systemName: "xmark.circle")

                    Text("Quit MacRadio")

                }

            }


        }
        .padding(12)
        .frame(width: 300)

    }

}
