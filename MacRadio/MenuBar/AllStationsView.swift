//
//  AllStationsView.swift
//  MacRadio
//

import SwiftUI


struct AllStationsView: View {

    @EnvironmentObject var appState: AppState

    @Binding var isPresented: Bool

    @State private var searchText = ""


    private var filteredStations: [RadioStation] {

        let query =
            searchText
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .lowercased()


        guard !query.isEmpty else {

            return appState.stationManager.stations
        }


        return appState.stationManager.stations.filter { station in

            let name =
                station.name.lowercased()

            let genre =
                station.genre?.lowercased() ?? ""

            let tags =
                station.tags?
                    .map {
                        $0.lowercased()
                    }
                    .joined(
                        separator: " "
                    )
                    ?? ""


            return name.contains(query)
                || genre.contains(query)
                || tags.contains(query)
        }
    }


    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            header

            searchField

            Divider()

            stationList
        }
        .padding(12)
        .frame(
            width: 320,
            height: 420
        )
    }


    private var header: some View {

        HStack {

            Button {

                isPresented = false

            } label: {

                Image(
                    systemName: "chevron.left"
                )
            }
            .buttonStyle(
                .plain
            )


            Text("All Stations")
                .font(.headline)


            Spacer()
        }
    }


    private var searchField: some View {

        TextField(
            "Search stations",
            text: $searchText
        )
        .textFieldStyle(
            .roundedBorder
        )
    }


    private var stationList: some View {

        ScrollView {

            LazyVStack(
                spacing: 4
            ) {

                ForEach(
                    filteredStations
                ) { station in

                    stationRow(
                        station
                    )
                }


                if filteredStations.isEmpty {

                    Text("No stations found")
                        .font(.caption)
                        .foregroundStyle(
                            .secondary
                        )
                        .padding(
                            .top,
                            20
                        )
                }
            }
        }
    }


    private func stationRow(
        _ station: RadioStation
    ) -> some View {

        HStack(
            spacing: 8
        ) {

            Button {

                select(
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
                            .foregroundStyle(
                                .secondary
                            )
                            .lineLimit(1)
                        }
                    }
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
        .padding(
            .vertical,
            3
        )
    }


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
            width: 32,
            height: 32
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 6
            )
        )
    }


    private var stationPlaceholder: some View {

        Image(
            systemName: "dot.radiowaves.left.and.right"
        )
        .frame(
            width: 32,
            height: 32
        )
        .background(
            Color.secondary.opacity(0.12)
        )
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


        isPresented = false
    }
}
