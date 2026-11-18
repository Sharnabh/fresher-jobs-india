import Foundation

enum APIEndpoint {
    case jobs(query: String, city: String, role: String, limit: Int, offset: Int)
    case sourcesStatus

    var path: String {
        switch self {
        case .jobs:
            "jobs"
        case .sourcesStatus:
            "sources/status"
        }
    }

    var method: String {
        switch self {
        case .jobs, .sourcesStatus:
            "GET"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case let .jobs(query, city, role, limit, offset):
            var items = [
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "offset", value: String(offset))
            ]
            if !query.isEmpty { items.append(URLQueryItem(name: "q", value: query)) }
            if !city.isEmpty { items.append(URLQueryItem(name: "city", value: city)) }
            if !role.isEmpty { items.append(URLQueryItem(name: "role", value: role)) }
            return items
        case .sourcesStatus:
            return []
        }
    }
}

protocol APIRequest {
    associatedtype Response: Decodable
    var endpoint: APIEndpoint { get }
}

struct GetJobsRequest: APIRequest {
    typealias Response = JobPageResponse

    let query: String
    let city: String
    let role: String
    let limit: Int
    let offset: Int

    var endpoint: APIEndpoint {
        .jobs(query: query, city: city, role: role, limit: limit, offset: offset)
    }
}

struct GetSyncStatusRequest: APIRequest {
    typealias Response = SyncStatusResponse
    var endpoint: APIEndpoint { .sourcesStatus }
}
