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
                .font(.headline)



            ScrollView {


                VStack(
                    spacing: 4
                ) {


                    ForEach(
                        appState.stationManager.stations
                    ) { station in


                        HStack {


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

                                }
                            }
                            .buttonStyle(
                                .plain
                            )



                            Spacer()



                            Button {


                                appState.stationManager.toggleFavorite(
                                    station
                                )


                            } label: {


                                Image(
                                    systemName:
                                        station.isFavorite
                                        ? "star.fill"
                                        : "star"
                                )

                            }
                            .buttonStyle(
                                .plain
                            )
                            .help(
                                station.isFavorite
                                ? "Remove from favorites"
                                : "Add to favorites"
                            )


                        }

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
