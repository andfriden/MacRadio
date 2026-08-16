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

        VStack(spacing: 10) {

            artworkView

            trackInfo

            playerState
        }
    }


    private var artworkView: some View {

        Group {

            if let image = artworkService.image {

                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()

            } else {

                Image(
                    systemName: "music.note"
                )
                .font(
                    .system(size: 42)
                )
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
            }
        }
        .frame(
            width: 180,
            height: 180
        )
        .background(
            Color.secondary.opacity(0.12)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 12
            )
        )
    }


    private var trackInfo: some View {

        VStack(spacing: 3) {

            Text(player.currentArtist)
                .font(.headline)
                .lineLimit(1)
                .truncationMode(.tail)


            Text(player.currentTitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)


            Text(currentStationName)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .frame(
            maxWidth: .infinity
        )
    }


    private var playerState: some View {

        HStack(spacing: 6) {

            Circle()
                .fill(stateColor)
                .frame(
                    width: 7,
                    height: 7
                )


            Text(stateText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }


    private var currentStationName: String {

        player.currentStation?.name
            ?? "No station selected"
    }


    private var stateText: String {

        switch player.state {

        case .playing:
            return "Playing"

        case .paused:
            return "Paused"

        case .connecting:
            return "Connecting..."

        case .stopped:
            return "Stopped"
        }
    }


    private var stateColor: Color {

        switch player.state {

        case .playing:
            return .green

        case .connecting:
            return .blue

        case .paused:
            return .gray

        case .stopped:
            return .red
        }
    }
}
