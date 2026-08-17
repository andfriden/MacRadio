//
//  MetadataService.swift
//  MacRadio
//

import Foundation
import Combine


final class MetadataService: ObservableObject {

    @Published var currentTrack: Track?


    private let metadataReader = ICYMetadataReader()

    private let parser = RadioMetadata()

    private let artworkService: ArtworkService

    private var artworkTask: Task<Void, Never>?

    private var artworkRequestID = UUID()


    init(
        artworkService: ArtworkService
    ) {
        self.artworkService = artworkService
    }


    // MARK: - Start

    func start(
        url: URL
    ) {

        metadataReader.onMetadataUpdate = { [weak self] metadata in

            guard let self else {
                return
            }


            self.parser.update(
                from: metadata
            )


            guard let track = self.validTrack() else {
                return
            }


            if let currentTrack = self.currentTrack,
               currentTrack.artist == track.artist,
               currentTrack.title == track.title {

                return
            }


            self.artworkTask?.cancel()


            let requestID = UUID()

            self.artworkRequestID = requestID


            DispatchQueue.main.async {

                guard
                    self.artworkRequestID == requestID
                else {
                    return
                }


                self.currentTrack = track
            }


            self.artworkTask = Task { [weak self] in

                guard let self else {
                    return
                }


                let artworkURL =
                    await self.artworkService.artwork(
                        for: track
                    )


                guard !Task.isCancelled else {
                    return
                }


                await MainActor.run {

                    guard
                        self.artworkRequestID == requestID
                    else {
                        return
                    }


                    self.artworkService.load(
                        from: artworkURL
                    )


                    self.currentTrack = Track(
                        artist: track.artist,
                        title: track.title,
                        artworkURL: artworkURL
                    )
                }
            }
        }


        metadataReader.start(
            url: url
        )
    }



    // MARK: - Stop

    func stop() {

        metadataReader.stop()

        parser.clear()


        artworkTask?.cancel()

        artworkTask = nil


        artworkRequestID = UUID()


        currentTrack = nil


        artworkService.load(
            from: nil
        )
    }



    // MARK: - Track Validation

    private func validTrack() -> Track? {

        let artist =
            parser.artist
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )


        let title =
            parser.title
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )


        guard !artist.isEmpty else {
            return nil
        }


        guard !title.isEmpty else {
            return nil
        }


        guard !isPlaceholder(title) else {
            return nil
        }


        return Track(
            artist: artist,
            title: title,
            artworkURL: nil
        )
    }



    private func isPlaceholder(
        _ value: String
    ) -> Bool {

        let normalized =
            value
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .lowercased()


        switch normalized {

        case "-",
             "—",
             "–",
             "n/a",
             "na",
             "unknown",
             "unk",
             "none":

            return true

        default:

            return false
        }
    }
}
