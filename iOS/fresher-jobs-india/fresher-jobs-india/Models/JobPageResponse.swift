import Foundation

struct JobPageResponse: Decodable {
    let items: [Job]
    let total: Int
    let limit: Int
    let offset: Int
}
