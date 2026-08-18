//
//  MetadataService.swift
//  MacRadio
//

import Foundation
import Combine


final class MetadataService: ObservableObject {

    @Published var currentTrack: Track?

    private let metadataReader = ICYMetadataReader()
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

        invalidateArtworkRequest()

        currentTrack = nil

        artworkService.load(
            from: nil
        )

        metadataReader.onMetadataUpdate = {
            [weak self] metadata in

            self?.handleMetadata(
                metadata
            )
        }

        metadataReader.start(
            url: url
        )
    }


    // MARK: - Stop

    func stop() {

        metadataReader.stop()

        invalidateArtworkRequest()

        currentTrack = nil

        artworkService.load(
            from: nil
        )
    }


    // MARK: - Metadata

    private func handleMetadata(
        _ streamTitle: String
    ) {

        guard let track =
            parseTrack(
                from: streamTitle
            )
        else {
            return
        }

        guard track != currentTrack else {
            return
        }

        artworkTask?.cancel()

        let requestID = UUID()

        artworkRequestID = requestID
        currentTrack = track

        artworkTask =
            Task { [weak self] in

                guard let self else {
                    return
                }

                let artworkURL =
                    await artworkService.artwork(
                        for: track
                    )

                guard !Task.isCancelled else {
                    return
                }

                await MainActor.run {

                    guard self.artworkRequestID ==
                            requestID
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

                    self.artworkTask = nil
                }
            }
    }


    // MARK: - Track Parsing

    private func parseTrack(
        from streamTitle: String
    ) -> Track? {

        let parts =
            streamTitle
                .split(
                    separator: "-",
                    maxSplits: 1,
                    omittingEmptySubsequences: true
                )
                .map {
                    $0
                        .trimmingCharacters(
                            in:
                                .whitespacesAndNewlines
                        )
                }

        guard parts.count == 2 else {
            return nil
        }

        let artist = parts[0]
        let title = parts[1]

        guard isValidMetadataValue(artist),
              isValidMetadataValue(title)
        else {
            return nil
        }

        return Track(
            artist: artist,
            title: title,
            artworkURL: nil
        )
    }


    // MARK: - Validation

    private func isValidMetadataValue(
        _ value: String
    ) -> Bool {

        let normalized =
            value
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                )
                .lowercased()

        guard !normalized.isEmpty else {
            return false
        }

        switch normalized {

        case "-",
             "—",
             "–",
             "n/a",
             "na",
             "unknown",
             "unk",
             "none":

            return false

        default:

            return true
        }
    }


    // MARK: - Artwork Request

    private func invalidateArtworkRequest() {

        artworkTask?.cancel()
        artworkTask = nil

        artworkRequestID = UUID()
    }
}
