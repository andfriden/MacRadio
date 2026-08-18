//
//  ICYMetadataReader.swift
//  MacRadio
//

import Foundation


final class ICYMetadataReader: NSObject, URLSessionDataDelegate {

    private var session: URLSession?
    private var task: URLSessionDataTask?


    private var metadataInterval: Int = 0
    private var buffer = Data()


    private var sessionID = UUID()


    var onMetadataUpdate: ((String) -> Void)?


    // MARK: - Start

    func start(
        url: URL
    ) {

        stop()

        let newSessionID = UUID()
        sessionID = newSessionID

        metadataInterval = 0
        buffer.removeAll()

        var request = URLRequest(
            url: url
        )

        request.setValue(
            "1",
            forHTTPHeaderField: "Icy-MetaData"
        )

        let configuration =
            URLSessionConfiguration.default

        let delegateQueue =
            OperationQueue()

        delegateQueue.maxConcurrentOperationCount = 1

        session =
            URLSession(
                configuration: configuration,
                delegate: self,
                delegateQueue: delegateQueue
            )

        task =
            session?.dataTask(
                with: request
            )

        task?.resume()
    }


    // MARK: - Stop

    func stop() {

        sessionID = UUID()

        task?.cancel()
        session?.invalidateAndCancel()

        task = nil
        session = nil

        metadataInterval = 0
        buffer.removeAll()
    }


    // MARK: - URLSession Response

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (
            URLSession.ResponseDisposition
        ) -> Void
    ) {

        guard session === self.session else {

            completionHandler(
                .cancel
            )

            return
        }

        guard dataTask === task else {

            completionHandler(
                .cancel
            )

            return
        }

        if let response =
            response as? HTTPURLResponse
        {

            metadataInterval =
                icyMetadataInterval(
                    from: response
                )
        }

        completionHandler(
            .allow
        )
    }


    // MARK: - URLSession Data

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {

        guard session === self.session else {
            return
        }

        guard dataTask === task else {
            return
        }

        guard !data.isEmpty else {
            return
        }

        buffer.append(
            data
        )

        processBuffer()
    }


    // MARK: - Buffer Processing

    private func processBuffer() {

        guard metadataInterval > 0 else {
            return
        }

        while true {

            guard
                buffer.count >= metadataInterval + 1
            else {
                return
            }

            let metadataLengthByte =
                buffer[
                    buffer.startIndex
                        .advanced(
                            by: metadataInterval
                        )
                ]

            let metadataLength =
                Int(
                    metadataLengthByte
                ) * 16

            let totalLength =
                metadataInterval
                + 1
                + metadataLength

            guard
                buffer.count >= totalLength
            else {
                return
            }

            if metadataLength > 0 {

                let metadataStart =
                    buffer.startIndex
                        .advanced(
                            by:
                                metadataInterval + 1
                        )

                let metadataEnd =
                    metadataStart
                        .advanced(
                            by: metadataLength
                        )

                let metadataData =
                    Data(
                        buffer[
                            metadataStart..<metadataEnd
                        ]
                    )

                parse(
                    metadataData
                )
            }

            buffer.removeFirst(
                totalLength
            )
        }
    }


    // MARK: - Metadata Parsing

    private func parse(
        _ data: Data
    ) {

        let text =
            decodeMetadata(
                data
            )
            .trimmingCharacters(
                in:
                    .whitespacesAndNewlines
                    .union(.controlCharacters)
            )

        guard !text.isEmpty else {
            return
        }

        guard
            let title =
                extractStreamTitle(
                    from: text
                )
        else {
            return
        }

        let cleanedTitle =
            title
                .replacingOccurrences(
                    of: "\0",
                    with: ""
                )
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                )

        guard !cleanedTitle.isEmpty else {
            return
        }

        let callbackSessionID =
            sessionID

        DispatchQueue.main.async { [weak self] in

            guard let self else {
                return
            }

            guard self.sessionID ==
                    callbackSessionID
            else {
                return
            }

            self.onMetadataUpdate?(
                cleanedTitle
            )
        }
    }


    // MARK: - Stream Title

    private func extractStreamTitle(
        from text: String
    ) -> String? {

        let marker = "StreamTitle="

        guard
            let markerRange =
                text.range(
                    of: marker,
                    options: .caseInsensitive
                )
        else {
            return nil
        }

        var valueStart =
            markerRange.upperBound

        while valueStart < text.endIndex {

            let character =
                text[valueStart]

            if character == "'" ||
               character == "\""
            {

                valueStart =
                    text.index(
                        after: valueStart
                    )

                break
            }

            if character.isWhitespace {

                valueStart =
                    text.index(
                        after: valueStart
                    )

                continue
            }

            break
        }

        var endIndex =
            valueStart

        while endIndex < text.endIndex {

            let character =
                text[endIndex]

            if character == "'" ||
               character == "\""
            {
                break
            }

            endIndex =
                text.index(
                    after: endIndex
                )
        }

        guard endIndex > valueStart else {
            return nil
        }

        return String(
            text[
                valueStart..<endIndex
            ]
        )
    }


    // MARK: - Decoding

    private func decodeMetadata(
        _ data: Data
    ) -> String {

        if let utf8 =
            String(
                data: data,
                encoding: .utf8
            )
        {
            return utf8
        }

        if let windows1252 =
            String(
                data: data,
                encoding:
                    .windowsCP1252
            )
        {
            return windows1252
        }

        if let isoLatin1 =
            String(
                data: data,
                encoding:
                    .isoLatin1
            )
        {
            return isoLatin1
        }

        return ""
    }


    // MARK: - Headers

    private func icyMetadataInterval(
        from response: HTTPURLResponse
    ) -> Int {

        for (key, value) in response.allHeaderFields {

            guard
                String(
                    describing: key
                )
                .caseInsensitiveCompare(
                    "icy-metaint"
                ) == .orderedSame
            else {
                continue
            }

            if let stringValue =
                value as? String,
               let interval =
                    Int(
                        stringValue.trimmingCharacters(
                            in:
                                .whitespacesAndNewlines
                        )
                    )
            {

                return max(
                    0,
                    interval
                )
            }

            if let number =
                value as? NSNumber
            {

                return max(
                    0,
                    number.intValue
                )
            }
        }

        return 0
    }
}
