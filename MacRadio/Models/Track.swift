//
//  Track.swift
//  MacRadio
//
//  Created by Андерс Фриден on 16.08.2026.
//

import Foundation


struct Track: Identifiable, Equatable {

    let id = UUID()

    var artist: String

    var title: String

    var artworkURL: URL?

}
