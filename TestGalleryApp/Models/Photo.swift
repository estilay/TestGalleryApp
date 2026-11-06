import Foundation

struct Photo: Decodable, Identifiable {
    let id: String
    let description: String?
    let altDescription: String?
    let urls: PhotoUrls
}
