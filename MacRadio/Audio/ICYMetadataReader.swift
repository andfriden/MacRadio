//
//  ICYMetadataReader.swift
//  MacRadio
//
//  Created by Андерс Фриден on 15.08.2026.
//

import Foundation


final class ICYMetadataReader: NSObject, URLSessionDataDelegate {


    private var session: URLSession?

    private var task: URLSessionDataTask?


    private var metadataInterval: Int = 0

    private var buffer = Data()


    var onMetadataUpdate: ((String) -> Void)?



    // MARK: - Start

    func start(
        url: URL
    ) {

        stop()

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


        session =
            URLSession(
                configuration: configuration,
                delegate: self,
                delegateQueue: OperationQueue()
            )


        task =
            session?.dataTask(
                with: request
            )


        task?.resume()
    }



    // MARK: - Stop

    func stop() {

        task?.cancel()

        session?.invalidateAndCancel()


        task = nil

        session = nil


        metadataInterval = 0

        buffer.removeAll()
    }



    // MARK: - URLSession

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (
            URLSession.ResponseDisposition
        ) -> Void
    ) {

        if let response =
            response as? HTTPURLResponse {

            if let value =
                response.allHeaderFields["icy-metaint"] as? String {

                metadataInterval =
                    Int(value) ?? 0
            }
        }


        completionHandler(
            .allow
        )
    }



    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {

        buffer.append(
            data
        )


        processBuffer()
    }



    // MARK: - Buffer Processing

    private func processBuffer() {

        while true {

            guard metadataInterval > 0 else {
                return
            }


            guard
                buffer.count >= metadataInterval + 1
            else {
                return
            }


            let lengthByte =
                Int(
                    buffer[
                        buffer.startIndex
                            .advanced(
                                by: metadataInterval
                            )
                    ]
                )


            let metadataLength =
                lengthByte * 16


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

                let metadataData =
                    Data(
                        buffer[
                            buffer.startIndex
                                .advanced(
                                    by: metadataInterval + 1
                                )
                            ..<
                            buffer.startIndex
                                .advanced(
                                    by: totalLength
                                )
                        ]
                    )


                if let metadata =
                    String(
                        data: metadataData,
                        encoding: .utf8
                    ) {

                    parse(
                        metadata
                    )
                }
            }


            buffer.removeFirst(
                totalLength
            )
        }
    }



    // MARK: - Metadata Parsing

    private func parse(
        _ text: String
    ) {

        guard
            let range =
                text.range(
                    of: "StreamTitle='"
                )
        else {
            return
        }


        let value =
            text[
                range.upperBound...
            ]


        guard
            let end =
                value.firstIndex(
                    of: "'"
                )
        else {
            return
        }


        let title =
            String(
                value[..<end]
            )


        guard !title.isEmpty else {
            return
        }


        DispatchQueue.main.async { [weak self] in

            self?.onMetadataUpdate?(
                title
            )
        }
    }
}
