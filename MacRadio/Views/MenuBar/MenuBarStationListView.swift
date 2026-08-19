//
//  MenuBarStationListView.swift
//  MacRadio
//

import SwiftUI


struct MenuBarStationListView: View {

    @EnvironmentObject var appState: AppState

    @State private var showingAllStations = false


    var body: some View {

        if showingAllStations {

            AllStationsView(
                isPresented: $showingAllStations
            )

        } else {

            recentStationsView
        }
    }


    // MARK: - Recent Stations

    private var recentStationsView: some View {

        VStack(
            alignment: .leading,
            spacing: 6
        ) {

            Text("Recent Stations")
                .font(.headline)


            if appState.stationManager.recentStations.isEmpty {

                Text("No recent stations")
                    .font(.caption)
                    .foregroundStyle(.secondary)

            } else {

                VStack(
                    spacing: 4
                ) {

                    ForEach(
                        appState.stationManager.recentStations
                    ) { station in

                        recentStationRow(
                            station
                        )
                    }
                }
            }


            Divider()


            HStack {

                Button {

                    showingAllStations = true

                } label: {

                    HStack(
                        spacing: 4
                    ) {

                        Text("All Stations")

                        Image(
                            systemName: "chevron.right"
                        )
                        .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)


                Spacer()


                SettingsLink {

                    HStack(
                        spacing: 4
                    ) {

                        Text("Settings")

                        Image(
                            systemName: "gearshape"
                        )
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .frame(
            width: 320
        )
    }


    // MARK: - Station Row

    private func recentStationRow(
        _ station: RadioStation
    ) -> some View {

        HStack(
            spacing: 8
        ) {

            Button {

                appState.playStation(
                    station
                )

            } label: {

                HStack(
                    spacing: 8
                ) {

                    stationArtwork(
                        station
                    )


                    VStack(
                        alignment: .leading,
                        spacing: 2
                    ) {

                        Text(
                            station.name
                        )
                        .lineLimit(1)


                        if let genre = station.genre {

                            Text(
                                genre
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        }
                    }


                    if isCurrent(
                        station
                    ) {

                        Image(
                            systemName: "checkmark.circle.fill"
                        )
                        .foregroundStyle(.secondary)
                    }
                }
            }
            .buttonStyle(.plain)


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
            .buttonStyle(.plain)
        }
    }


    // MARK: - Artwork

    private func stationArtwork(
        _ station: RadioStation
    ) -> some View {

        Group {

            if let url = station.artworkURL {

                AsyncImage(
                    url: url
                ) { image in

                    image
                        .resizable()
                        .scaledToFill()

                } placeholder: {

                    stationPlaceholder
                }

            } else {

                stationPlaceholder
            }
        }
        .frame(
            width: 24,
            height: 24
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 5
            )
        )
    }


    private var stationPlaceholder: some View {

        Image(
            systemName: "radio"
        )
        .frame(
            width: 24,
            height: 24
        )
        .background(
            Color.secondary.opacity(0.12)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 5
            )
        )
    }


    // MARK: - Helpers

    private func isCurrent(
        _ station: RadioStation
    ) -> Bool {

        appState.player.currentStation?.id == station.id
    }
}
