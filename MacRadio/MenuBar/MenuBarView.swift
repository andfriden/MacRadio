import SwiftUI


struct MenuBarView: View {


    @EnvironmentObject var appState: AppState



    var body: some View {


        VStack(spacing: 12) {


            Image(systemName: "dot.radiowaves.left.and.right")
                .font(.system(size: 28))



            Text("MacRadio")
                .font(.headline)



            Divider()



            if let station = appState.player.currentStation {


                VStack {


                    Text(station.name)
                        .font(.headline)



                    Text(appState.player.state.description)
                        .foregroundStyle(.secondary)


                }


            } else {


                Text("No station selected")
                    .foregroundStyle(.secondary)


            }




            Divider()




            ForEach(appState.stationManager.stations) { station in



                Button {


                    appState.stationManager.select(
                        station
                    )


                    appState.player.play(
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


                    appState.player.pause()



                } label: {


                    Image(systemName: "pause.fill")


                }





                Button {



                    if let station = appState.stationManager.currentStation {



                        appState.player.play(
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


    }

}
