//
//  RadioStation.swift
//  MacRadio
//

import Foundation


struct RadioStation: Identifiable, Codable {


    let id: UUID

    let name: String

    let genre: String?

    let streamURL: URL

    let artworkURL: URL?


    // Дополнительно для библиотеки

    let country: String?

    let tags: [String]?


    var isFavorite: Bool = false



    init(
        id: UUID = UUID(),
        name: String,
        genre: String? = nil,
        streamURL: URL,
        artworkURL: URL? = nil,
        country: String? = nil,
        tags: [String]? = [],
        isFavorite: Bool = false
    ) {

        self.id = id

        self.name = name

        self.genre = genre

        self.streamURL = streamURL

        self.artworkURL = artworkURL

        self.country = country

        self.tags = tags

        self.isFavorite = isFavorite

    }
    private enum CodingKeys: String, CodingKey {

        case id
        case name
        case genre
        case streamURL
        case artworkURL
        case country
        case tags
        case isFavorite

    }



    init(
        from decoder: Decoder
    ) throws {


        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )


        id = try container.decode(
            UUID.self,
            forKey: .id
        )


        name = try container.decode(
            String.self,
            forKey: .name
        )


        genre = try container.decodeIfPresent(
            String.self,
            forKey: .genre
        )


        streamURL = try container.decode(
            URL.self,
            forKey: .streamURL
        )


        artworkURL = try container.decodeIfPresent(
            URL.self,
            forKey: .artworkURL
        )


        country = try container.decodeIfPresent(
            String.self,
            forKey: .country
        )


        tags = try container.decodeIfPresent(
            [String].self,
            forKey: .tags
        )


        isFavorite = try container.decodeIfPresent(
            Bool.self,
            forKey: .isFavorite
        ) ?? false

    }
}
