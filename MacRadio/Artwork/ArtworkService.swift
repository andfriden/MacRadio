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

    private var imageTask: URLSessionDataTask?

    private var loadID = UUID()


    init(
        session: URLSession = .shared
    ) {

        self.session = session


        imageCache.countLimit = 50

        imageCache.totalCostLimit =
            50 * 1024 * 1024
    }


    // MARK: - Artwork Search


    func artwork(
        for track: Track
    ) async -> URL? {

        let artist =
            track.artist
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )


        let title =
            track.title
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )


        guard !artist.isEmpty,
              !title.isEmpty
        else {

            return nil
        }


        let key =
            cacheKey(
                artist: artist,
                title: title
            )


        if let cachedURL =
            artworkCache[key]
        {

            return cachedURL
        }


        guard var components =
            URLComponents(
                string:
                    "https://itunes.apple.com/search"
            )
        else {

            return nil
        }


        components.queryItems = [

            URLQueryItem(
                name: "term",
                value:
                    "\(artist) \(title)"
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


        guard let url =
            components.url
        else {

            return nil
        }


        do {

            let (data, response) =
                try await session.data(
                    from: url
                )


            guard
                let httpResponse =
                    response as? HTTPURLResponse,
                200..<300 ~=
                    httpResponse.statusCode
            else {

                return nil
            }


            let searchResponse =
                try JSONDecoder().decode(
                    SearchResponse.self,
                    from: data
                )


            guard let artworkURL =
                bestMatch(
                    results:
                        searchResponse.results,
                    artist: artist,
                    title: title
                )
            else {

                return nil
            }


            let highResolutionURL =
                makeHighResolutionURL(
                    artworkURL
                )


            artworkCache[key] =
                highResolutionURL


            return highResolutionURL

        } catch {

            guard !isCancellationError(
                error
            ) else {

                return nil
            }


            print(
                "ARTWORK SEARCH ERROR:",
                error
            )


            return nil
        }
    }


    // MARK: - Image Loading


    func load(
        from url: URL?
    ) {

        imageTask?.cancel()

        imageTask = nil


        let currentLoadID =
            UUID()


        loadID =
            currentLoadID


        guard let url else {

            image = nil

            return
        }


        if let cachedImage =
            imageCache.object(
                forKey:
                    url as NSURL
            )
        {

            image = cachedImage

            return
        }


        image = nil


        imageTask =
            session.dataTask(
                with: url
            ) { [weak self] data, response, error in

                guard let self else {

                    return
                }


                guard error == nil else {

                    return
                }


                guard
                    let response =
                        response as? HTTPURLResponse,
                    200..<300 ~=
                        response.statusCode
                else {

                    return
                }


                guard
                    let data,
                    let image =
                        NSImage(
                            data: data
                        )
                else {

                    return
                }


                DispatchQueue.main.async {

                    guard
                        self.loadID ==
                            currentLoadID
                    else {

                        return
                    }


                    self.imageCache.setObject(
                        image,
                        forKey:
                            url as NSURL,
                        cost:
                            data.count
                    )


                    self.image =
                        image


                    self.imageTask =
                        nil
                }
            }


        imageTask?.resume()
    }


    // MARK: - Search Helpers


    private func bestMatch(
        results: [Result],
        artist: String,
        title: String
    ) -> URL? {

        let normalizedArtist =
            normalize(
                artist
            )


        let normalizedTitle =
            normalize(
                title
            )


        if let exactMatch =
            results.first(
                where: { result in

                    normalize(
                        result.artistName ?? ""
                    ) == normalizedArtist
                    &&
                    normalize(
                        result.trackName ?? ""
                    ) == normalizedTitle
                }
            )
        {

            return exactMatch.artworkUrl100
        }


        return results
            .compactMap {
                $0.artworkUrl100
            }
            .first
    }


    private func makeHighResolutionURL(
        _ url: URL
    ) -> URL {

        let string =
            url.absoluteString
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
                in:
                    .whitespacesAndNewlines
            )
            .replacingOccurrences(
                of: "\\s+",
                with: " ",
                options:
                    .regularExpression
            )
    }


    private func isCancellationError(
        _ error: Error
    ) -> Bool {

        if
            let urlError =
                error as? URLError,
            urlError.code ==
                .cancelled
        {

            return true
        }


        return false
    }
}
