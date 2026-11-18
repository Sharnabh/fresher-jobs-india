import Foundation

struct Job: Codable, Identifiable, Hashable {
    let id: String
    let sourceURL: URL
    let company: String
    let title: String
    let city: String
    let role: String
    let jobType: String
    let postedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, company, title, city, role
        case sourceURL = "source_url"
        case jobType = "job_type"
        case postedAt = "posted_at"
    }

    var postedDate: Date? {
        guard let postedAt else { return nil }
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = fractional.date(from: postedAt) { return date }
        let standard = ISO8601DateFormatter()
        standard.formatOptions = [.withInternetDateTime]
        return standard.date(from: postedAt)
    }
}
