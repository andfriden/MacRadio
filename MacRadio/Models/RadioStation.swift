import Foundation


struct RadioStation: Identifiable, Codable {

    let id: UUID
    let name: String
    let genre: String?
    let streamURL: URL
    let artworkURL: URL?


}
