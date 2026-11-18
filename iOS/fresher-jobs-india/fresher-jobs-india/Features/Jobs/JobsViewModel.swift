import Foundation
import Observation

@Observable
@MainActor
final class JobsViewModel {
    static let pageSize = 50
    static let roles = [
        "Software Engineering", "Data", "Product", "Design", "Marketing",
        "Sales", "Finance", "Operations", "Customer Support", "Other"
    ]

    var jobs: [Job] = []
    var total = 0
    var isLoading = false
    var isLoadingMore = false
    var errorMessage: String?
    var syncStatus: SyncStatusResponse?
    var searchText = ""
    var cityText = ""
    var selectedRole = ""

    let isPreview: Bool
    private let apiService: APIService

    var filterKey: String {
        "\(searchText)|\(cityText)|\(selectedRole)"
    }

    var hasMore: Bool { jobs.count < total }

    init(apiService: APIService? = nil, preview: Bool = false) {
        self.apiService = apiService ?? APIService()
        self.isPreview = preview
        if preview {
            jobs = Self.previewJobs
            total = 106
            syncStatus = SyncStatusResponse(
                configuredBoards: 324,
                activeJobs: 106,
                syncing: false,
                lastRun: nil
            )
        }
    }

    func loadFirstPage() async {
        guard !isPreview else { return }
        let requestedFilterKey = filterKey
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let request = GetJobsRequest(
                query: searchText.trimmingCharacters(in: .whitespacesAndNewlines),
                city: cityText.trimmingCharacters(in: .whitespacesAndNewlines),
                role: selectedRole,
                limit: Self.pageSize,
                offset: 0
            )
            let page = try await apiService.send(request)
            guard !Task.isCancelled, filterKey == requestedFilterKey else { return }
            jobs = page.items
            total = page.total
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            errorMessage = error.localizedDescription
        }
    }

    func loadMore() async {
        guard !isPreview, hasMore, !isLoadingMore else { return }
        let requestedFilterKey = filterKey
        isLoadingMore = true
        errorMessage = nil
        defer { isLoadingMore = false }

        do {
            let request = GetJobsRequest(
                query: searchText.trimmingCharacters(in: .whitespacesAndNewlines),
                city: cityText.trimmingCharacters(in: .whitespacesAndNewlines),
                role: selectedRole,
                limit: Self.pageSize,
                offset: jobs.count
            )
            let page = try await apiService.send(request)
            guard !Task.isCancelled, filterKey == requestedFilterKey else { return }
            let knownIDs = Set(jobs.map(\.id))
            jobs.append(contentsOf: page.items.filter { !knownIDs.contains($0.id) })
            total = page.total
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refresh() async {
        await loadFirstPage()
        await refreshStatus()
    }

    func refreshStatus() async {
        guard !isPreview else { return }
        do {
            syncStatus = try await apiService.send(GetSyncStatusRequest())
        } catch {
            if jobs.isEmpty { errorMessage = error.localizedDescription }
        }
    }

    private static let previewJobs = [
        Job(
            id: "preview-1",
            sourceURL: URL(string: "https://example.com/jobs/1")!,
            company: "Landor",
            title: "Springboard Internship — Client Services",
            city: "Delhi",
            role: "Operations",
            jobType: "Internship",
            postedAt: "2026-11-17T00:51:04-05:00"
        ),
        Job(
            id: "preview-2",
            sourceURL: URL(string: "https://example.com/jobs/2")!,
            company: "Atlys",
            title: "Product Design Intern",
            city: "Bengaluru",
            role: "Design",
            jobType: "Internship",
            postedAt: nil
        ),
        Job(
            id: "preview-3",
            sourceURL: URL(string: "https://example.com/jobs/3")!,
            company: "Sarvam AI",
            title: "Associate Software Engineer",
            city: "Bengaluru",
            role: "Software Engineering",
            jobType: "Full-time",
            postedAt: nil
        )
    ]
}
