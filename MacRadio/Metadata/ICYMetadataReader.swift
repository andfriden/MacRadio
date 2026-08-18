//
//  ICYMetadataReader.swift
//  MacRadio
//

import Foundation


final class ICYMetadataReader: NSObject, URLSessionDataDelegate {

    private var session: URLSession?
    private var task: URLSessionDataTask?

    private var metadataInterval = 0
    private var buffer = Data()

    // Identifies the currently active metadata session and prevents
    // callbacks from an older station/session from updating the UI.
    private var currentSessionID = UUID()

    var onMetadataUpdate: ((String) -> Void)?


    // MARK: - Start

    func start(
        url: URL
    ) {

        stop()

        let newSessionID = UUID()

        currentSessionID = newSessionID
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

        session = URLSession(
            configuration: configuration,
            delegate: self,
            delegateQueue: delegateQueue
        )

        task = session?.dataTask(
            with: request
        )

        task?.resume()
    }


    // MARK: - Stop

    func stop() {

        currentSessionID = UUID()

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

        guard ensureValid(
            session: session,
            dataTask: dataTask
        ) else {

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

        guard ensureValid(
            session: session,
            dataTask: dataTask
        ) else {
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

        // ICY protocol:
        // audio data is delivered in blocks of `metadataInterval` bytes.
        // The following byte contains the metadata length in 16-byte units,
        // followed by the metadata block itself.

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
            .trimmedForMetadata

        guard !text.isEmpty else {
            return
        }

        guard let title =
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
                .trimmedForMetadata

        guard !cleanedTitle.isEmpty else {
            return
        }

        let callbackSessionID =
            currentSessionID

        DispatchQueue.main.async { [weak self] in

            guard let self else {
                return
            }

            guard self.currentSessionID ==
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

        guard let range = text.range(
            of: marker,
            options: .caseInsensitive
        ) else {
            return nil
        }

        var start = range.upperBound

        while start < text.endIndex,
              text[start].isWhitespace
        {
            start = text.index(
                after: start
            )
        }

        guard start < text.endIndex else {
            return nil
        }

        let firstCharacter = text[start]

        if firstCharacter == "'" ||
           firstCharacter == "\""
        {

            start = text.index(
                after: start
            )

            guard let end = text[start...]
                .firstIndex(
                    of: firstCharacter
                )
            else {
                return nil
            }

            return String(
                text[start..<end]
            )
        }

        var end = start

        while end < text.endIndex,
              !text[end].isWhitespace
        {
            end = text.index(
                after: end
            )
        }

        guard end > start else {
            return nil
        }

        return String(
            text[start..<end]
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
                encoding: .windowsCP1252
            )
        {
            return windows1252
        }

        if let isoLatin1 =
            String(
                data: data,
                encoding: .isoLatin1
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

        guard let header =
            response.allHeaderFields.first(
                where: { key, _ in

                    String(
                        describing: key
                    )
                    .caseInsensitiveCompare(
                        "icy-metaint"
                    ) == .orderedSame
                }
            )
        else {
            return 0
        }

        if let stringValue =
            header.value as? String,
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
            header.value as? NSNumber
        {
            return max(
                0,
                number.intValue
            )
        }

        return 0
    }


    // MARK: - Validation

    private func ensureValid(
        session: URLSession,
        dataTask: URLSessionDataTask
    ) -> Bool {

        session === self.session &&
        dataTask === self.task
    }
}


// MARK: - Metadata String Helpers

private extension String {

    var trimmedForMetadata: String {

        trimmingCharacters(
            in:
                .whitespacesAndNewlines
                .union(.controlCharacters)
        )
    }
}
