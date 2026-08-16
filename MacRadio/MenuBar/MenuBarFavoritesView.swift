//
//  MenuBarFavoritesView.swift
//  MacRadio
//

import SwiftUI


struct MenuBarFavoritesView: View {


    @EnvironmentObject var appState: AppState



    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 6
        ) {

            Text("Favorites")
                .font(.headline)



            if appState.stationManager.favoriteStations.isEmpty {


                Text("No favorites")
                    .font(.caption)
                    .foregroundStyle(
                        .secondary
                    )


            } else {


                ForEach(
                    appState.stationManager.favoriteStations
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
                                systemName: "star.fill"
                            )


                            Text(
                                station.name
                            )
                            .lineLimit(1)


                            Spacer()

                        }

                    }
                    .buttonStyle(
                        .plain
                    )
                }
            }
        }
    }
}
