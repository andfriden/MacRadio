//
//  MenuBarStationListView.swift
//  MacRadio
//

import SwiftUI


struct MenuBarStationListView: View {

    @EnvironmentObject var appState: AppState



    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 6
        ) {

            Text("Stations")
                .font(
                    .headline
                )



            ScrollView {

                VStack(
                    spacing: 4
                ) {

                    ForEach(
                        appState.stationManager.stations
                    ) { station in


                        Button {

                            select(
                                station
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
                                .lineLimit(
                                    1
                                )



                                Spacer()

                            }
                        }
                        .buttonStyle(
                            .plain
                        )
                    }
                }
            }
            .frame(
                maxHeight: 180
            )
        }
    }



    private func select(
        _ station: RadioStation
    ) {

        appState.stationManager.select(
            station
        )


        appState.player.play(
            station: station
        )
    }



    private func isCurrent(
        _ station: RadioStation
    ) -> Bool {

        appState.player.currentStation?.id ==
        station.id
    }
}
