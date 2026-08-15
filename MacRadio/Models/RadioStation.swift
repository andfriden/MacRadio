import Foundation


struct RadioStation: Identifiable, Codable {

    let id: UUID
    let name: String
    let url: URL


    init(
        id: UUID = UUID(),
        name: String,
        url: URL
    ) {
        self.id = id
        self.name = name
        self.url = url
    }
}
