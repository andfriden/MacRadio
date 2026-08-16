//
//  MetadataService.swift
//  MacRadio
//
//  Created by Андерс Фриден on 16.08.2026.
//

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
    
    private let artworkService = ArtworkService()

    private var artworkTask: Task<Void, Never>?



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

            self.currentTrack = track

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

        currentTrack = nil

    }

}
