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


            self.currentTrack = Track(
                artist: self.parser.artist,
                title: self.parser.title,
                artworkURL: nil
            )

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
