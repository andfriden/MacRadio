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


    init(
        artworkService: ArtworkService
    ) {
        self.artworkService = artworkService
    }


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


            let track = Track(
                artist: self.parser.artist,
                title: self.parser.title,
                artworkURL: nil
            )


            DispatchQueue.main.async {

                self.currentTrack = track

            }


            self.artworkTask?.cancel()


            self.artworkTask = Task { [weak self] in

                guard let self else {
                    return
                }


                let artworkURL = await self.artworkService.artwork(
                    for: track
                )


                guard !Task.isCancelled else {
                    return
                }


                await MainActor.run {

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


    func stop() {

        metadataReader.stop()

        parser.clear()

        artworkTask?.cancel()

        artworkTask = nil

        currentTrack = nil

        artworkService.load(
            from: nil
        )
    }
}
