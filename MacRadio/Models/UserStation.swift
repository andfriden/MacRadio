//
//  UserStation.swift
//  MacRadio
//

import Foundation


struct UserStation: Codable {

    let id: UUID?
    let name: String
    let genre: String?
    let streamURL: URL
    let artworkURL: URL?
    let country: String?
    let tags: [String]?


    func makeRadioStation() -> RadioStation {

        RadioStation(
            id: id ?? UUID(),
            name: name,
            genre: genre,
            streamURL: streamURL,
            artworkURL: artworkURL,
            country: country,
            tags: tags ?? [],
            isFavorite: false
        )
    }
}
