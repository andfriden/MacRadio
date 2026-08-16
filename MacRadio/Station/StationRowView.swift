//
//  StationRowView.swift
//  MacRadio
//

import SwiftUI


struct StationRowView: View {

    let station: RadioStation

    @EnvironmentObject private var stationManager: StationManager


    private var isCurrentStation: Bool {

        stationManager.currentStation?.id == station.id
    }


    var body: some View {

        HStack(spacing: 12) {

            Image(
                systemName: isCurrentStation
                ? "waveform"
                : "radio"
            )


            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text(
                    station.name
                )
                .font(
                    .headline
                )


                if let genre = station.genre {

                    Text(
                        genre
                    )
                    .font(
                        .caption
                    )
                    .foregroundStyle(
                        .secondary
                    )
                }
            }


            Spacer()


            Button {

                stationManager.toggleFavorite(
                    station
                )

            } label: {

                Image(
                    systemName: station.isFavorite
                    ? "star.fill"
                    : "star"
                )
            }
            .buttonStyle(
                .plain
            )
        }
        .padding()
        .contentShape(
            Rectangle()
        )
        .onTapGesture {

            stationManager.select(
                station
            )
        }
   }
}
