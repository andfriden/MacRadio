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


            Button {

                showingAllStations = true

            } label: {

                HStack {

                    Text("All Stations")

                    Spacer()

                    Image(
                        systemName: "chevron.right"
                    )
                    .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
            .padding(
                .top,
                4
            )
        }
    }


    // MARK: - Station Row

    private func recentStationRow(
        _ station: RadioStation
    ) -> some View {

        HStack {

            Button {

                appState.playStation(
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
                    .lineLimit(1)
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
            .help(
                station.isFavorite
                ? "Remove from favorites"
                : "Add to favorites"
            )
        }
    }


    // MARK: - Helpers

    private func isCurrent(
        _ station: RadioStation
    ) -> Bool {

        appState.player.currentStation?.id ==
            station.id
    }
}
