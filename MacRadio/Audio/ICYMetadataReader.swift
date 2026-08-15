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


        let configuration = URLSessionConfiguration.default


        session = URLSession(
            configuration: configuration,
            delegate: self,
            delegateQueue: OperationQueue()
        )


        task = session?.dataTask(
            with: request
        )


        task?.resume()

    }



    func stop() {

        task?.cancel()

        session?.invalidateAndCancel()

        task = nil

        session = nil

        buffer.removeAll()

    }



    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {


        if let response = response as? HTTPURLResponse {


            if let value = response.allHeaderFields["icy-metaint"] as? String {

                metadataInterval = Int(value) ?? 0

            }

        }


        completionHandler(.allow)

    }



    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {


        buffer.append(data)

        processBuffer()

    }



    private func processBuffer() {


        while true {


            guard metadataInterval > 0 else {

                return

            }


            guard buffer.count >= metadataInterval else {

                return

            }



            buffer.removeFirst(
                metadataInterval
            )



            guard !buffer.isEmpty else {

                return

            }



            let lengthByte = Int(
                buffer.removeFirst()
            )


            let metadataLength = lengthByte * 16



            guard buffer.count >= metadataLength else {

                return

            }



            let metadataData = buffer.prefix(
                metadataLength
            )


            buffer.removeFirst(
                metadataLength
            )



            if let metadata = String(
                data: metadataData,
                encoding: .utf8
            ) {


                parse(
                    metadata
                )

            }

        }

    }



    private func parse(
        _ text: String
    ) {


        guard let range = text.range(
            of: "StreamTitle='"
        )
        else {

            return

        }



        let value = text[
            range.upperBound...
        ]



        if let end = value.firstIndex(
            of: "'"
        ) {


            let title = String(
                value[..<end]
            )


            DispatchQueue.main.async { [weak self] in

                self?.onMetadataUpdate?(
                    title
                )

            }

        }

    }

}
