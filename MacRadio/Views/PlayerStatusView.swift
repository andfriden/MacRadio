//
//  PlayerStatusView.swift
//  MacRadio
//

import SwiftUI
import AppKit


struct PlayerStatusView: View {


    @ObservedObject var player: RadioPlayer


    @ObservedObject var artworkService: ArtworkService



    var body: some View {


        HStack(
            spacing: 8
        ) {


            artworkView



            contentView


        }
        .frame(
            height: 32
        )

    }



    private var artworkView: some View {


        Group {


            if let image =
                artworkService.image {


                Image(
                    nsImage: image
                )
                .resizable()
                .scaledToFill()


            } else {


                Image(
                    systemName: "dot.radiowaves.left.and.right"
                )
                .font(
                    .system(size: 18)
                )

            }

        }
        .frame(
            width: 28,
            height: 28
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 5
            )
        )

    }



    private var contentView: some View {

        Group {

            switch player.state {


            case .playing:

                MarqueeText(
                    text: currentTrackText
                )
                .frame(
                    height: 18
                )



            case .paused:

                Text(
                    currentStationName
                )
                .lineLimit(
                    1
                )



            case .connecting:

                Text(
                    "Connecting..."
                )



            case .stopped:

                Text(
                    "Stopped"
                )

            }

        }

    }



    private var currentStationName: String {


        player.currentStation?.name
        ?? "MacRadio"

    }




    private var currentTrackText: String {


        let artist =
            player.currentArtist


        let title =
            player.currentTitle



        if !artist.isEmpty &&
            !title.isEmpty {


            return "\(artist) — \(title) • \(currentStationName)"

        }


        return currentStationName

    }

}
