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

            if player.state == .connecting {

                Text(
                    "Connecting…"
                )
                .font(.headline)

            } else if player.state == .playing ||
                      player.state == .paused {

                Text(
                    player.currentArtist.isEmpty
                    ? "Unknown Artist"
                    : player.currentArtist
                )
                .font(.headline)
                .lineLimit(1)
                .truncationMode(.tail)


                Text(
                    player.currentTitle.isEmpty
                    ? "Unknown Track"
                    : player.currentTitle
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)


                Text(
                    currentStationName
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)

            } else {

                Text(
                    "No station selected"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .frame(
            maxWidth: .infinity
        )
    }


    private var currentStationName: String {

        player.currentStation?.name
            ?? "No station selected"
    }
}
