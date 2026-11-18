import Foundation

struct SyncStatusResponse: Decodable {
    let configuredBoards: Int
    let activeJobs: Int
    let syncing: Bool
    let lastRun: SyncRunResponse?

    enum CodingKeys: String, CodingKey {
        case configuredBoards = "configured_boards"
        case activeJobs = "active_jobs"
        case syncing
        case lastRun = "last_run"
    }
}

struct SyncRunResponse: Decodable {
    let status: String
    let boardsSynced: Int?
    let finishedAt: String?

    enum CodingKeys: String, CodingKey {
        case status
        case boardsSynced = "boards_synced"
        case finishedAt = "finished_at"
    }
}
