//
//  PlayerStatusView.swift
//  MacRadio
//

import SwiftUI


struct PlayerStatusView: View {


    @ObservedObject var player: RadioPlayer



    var body: some View {


        switch player.state {


        case .playing:


            HStack(spacing: 6) {


                Image(
                    systemName: "play.fill"
                )
                .font(.system(size: 12))
                .frame(
                    width: 14,
                    height: 14
                )



                MarqueeText(
                    text: currentTrackText
                )
                .frame(
                    height: 18
                )


            }
            .frame(
                height: 18
            )





        case .paused:


            HStack(spacing: 6) {


                Image(
                    systemName: "pause.fill"
                )
                .font(.system(size: 12))



                Text(
                    currentStationName
                )
                .lineLimit(1)


            }





        case .connecting:


            HStack(spacing: 6) {


                Image(
                    systemName: "arrow.triangle.2.circlepath"
                )


                Text(
                    "Connecting..."
                )


            }





        case .stopped:


            HStack(spacing: 6) {


                Image(
                    systemName: "stop.fill"
                )


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


        let station =
        currentStationName



        if !artist.isEmpty &&
            !title.isEmpty {


            return "\(artist) — \(title)  •  \(station)"

        }



        return station

    }


}
