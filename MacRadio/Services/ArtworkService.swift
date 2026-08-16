//
//  ArtworkService.swift
//  MacRadio
//

import Foundation
import AppKit
import Combine


final class ArtworkService: ObservableObject {

    @Published var image: NSImage?


    private struct SearchResponse: Decodable {
        let results: [Result]
    }


    private struct Result: Decodable {
        let artistName: String?
        let trackName: String?
        let artworkUrl100: URL?
    }


    private let session: URLSession

    private let imageCache = NSCache<NSURL, NSImage>()

    private var artworkCache: [String: URL] = [:]


    init(
        session: URLSession = .shared
    ) {
        self.session = session
    }


    // MARK: - Artwork Search

    func artwork(
        for track: Track
    ) async -> URL? {

        let key = cacheKey(
            artist: track.artist,
            title: track.title
        )


        if let cachedURL = artworkCache[key] {
            return cachedURL
        }


        guard
            !track.artist.isEmpty,
            !track.title.isEmpty
        else {
            return nil
        }


        guard var components = URLComponents(
            string: "https://itunes.apple.com/search"
        ) else {
            return nil
        }


        components.queryItems = [

            URLQueryItem(
                name: "term",
                value: "\(track.artist) \(track.title)"
            ),

            URLQueryItem(
                name: "country",
                value: "US"
            ),

            URLQueryItem(
                name: "media",
                value: "music"
            ),

            URLQueryItem(
                name: "entity",
                value: "musicTrack"
            ),

            URLQueryItem(
                name: "limit",
                value: "5"
            )
        ]


        guard let url = components.url else {
            return nil
        }


        do {

            let (data, response) = try await session.data(
                from: url
            )


            guard
                let httpResponse = response as? HTTPURLResponse,
                200..<300 ~= httpResponse.statusCode
            else {
                return nil
            }


            let searchResponse = try JSONDecoder().decode(
                SearchResponse.self,
                from: data
            )


            guard let artworkURL = bestMatch(
                results: searchResponse.results,
                track: track
            ) else {
                return nil
            }


            let highResolutionURL = makeHighResolutionURL(
                artworkURL
            )


            artworkCache[key] = highResolutionURL

            return highResolutionURL

        } catch {

            print(
                "ARTWORK ERROR:",
                error
            )

            return nil
        }
    }


    // MARK: - Image Loading

    func load(
        from url: URL?
    ) {

        guard let url else {

            image = nil

            return
        }


        if let cachedImage = imageCache.object(
            forKey: url as NSURL
        ) {

            image = cachedImage

            return
        }


        session.dataTask(
            with: url
        ) { [weak self] data, _, _ in

            guard
                let data,
                let image = NSImage(
                    data: data
                )
            else {
                return
            }


            DispatchQueue.main.async {

                self?.imageCache.setObject(
                    image,
                    forKey: url as NSURL
                )


                self?.image = image
            }

        }
        .resume()
    }


    // MARK: - Search Helpers

    private func bestMatch(
        results: [Result],
        track: Track
    ) -> URL? {

        let normalizedArtist = normalize(
            track.artist
        )

        let normalizedTitle = normalize(
            track.title
        )


        if let exactMatch = results.first(where: { result in

            normalize(
                result.artistName ?? ""
            ) == normalizedArtist

            &&

            normalize(
                result.trackName ?? ""
            ) == normalizedTitle

        }) {

            return exactMatch.artworkUrl100
        }


        return results.first?.artworkUrl100
    }


    private func makeHighResolutionURL(
        _ url: URL
    ) -> URL {

        let string = url.absoluteString
            .replacingOccurrences(
                of: "100x100bb",
                with: "600x600bb"
            )


        return URL(
            string: string
        ) ?? url
    }


    private func cacheKey(
        artist: String,
        title: String
    ) -> String {

        "\(normalize(artist))|\(normalize(title))"
    }


    private func normalize(
        _ value: String
    ) -> String {

        value
            .lowercased()
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .replacingOccurrences(
                of: "\\s+",
                with: " ",
                options: .regularExpression
            )
    }
}
