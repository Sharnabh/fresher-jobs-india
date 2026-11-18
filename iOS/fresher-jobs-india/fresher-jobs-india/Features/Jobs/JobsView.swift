import SwiftUI

struct JobsView: View {
    @State private var viewModel: JobsViewModel
    @State private var selectedJob: Job?

    @MainActor
    init(viewModel: JobsViewModel? = nil) {
        _viewModel = State(initialValue: viewModel ?? JobsViewModel())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    introduction
                    filters
                    resultsHeader
                    listings
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 12)
                .frame(maxWidth: 760)
                .frame(maxWidth: .infinity)
            }
            .background(JobPalette.canvas.ignoresSafeArea())
            .scrollIndicators(.hidden)
            .refreshable { await viewModel.refresh() }
            .toolbar(.hidden, for: .navigationBar)
            .task(id: viewModel.filterKey) {
                guard !viewModel.isPreview else { return }
                do {
                    try await Task.sleep(for: .milliseconds(300))
                } catch {
                    return
                }
                await viewModel.loadFirstPage()
            }
            .task {
                guard !viewModel.isPreview else { return }
                await viewModel.refreshStatus()
                while !Task.isCancelled, viewModel.syncStatus?.syncing == true {
                    do {
                        try await Task.sleep(for: .seconds(5))
                    } catch {
                        return
                    }
                    await viewModel.refreshStatus()
                }
            }
            .sheet(item: $selectedJob) { job in
                JobDetailView(job: job)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .tint(JobPalette.green)
    }

    private var header: some View {
        HStack(alignment: .center) {
            HStack(spacing: 10) {
                Text("F")
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundStyle(JobPalette.green)
                    .frame(width: 38, height: 38)
                    .background(JobPalette.lime, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .accessibilityHidden(true)
                Text("firststep")
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .tracking(-0.6)
                    .foregroundStyle(JobPalette.ink)
                Text(".")
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .foregroundStyle(JobPalette.green)
                    .padding(.leading, -10)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("FirstStep")

            Spacer()
            SyncStatusPill(status: viewModel.syncStatus)
        }
    }

    private var introduction: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(spacing: 8) {
                Circle().fill(JobPalette.green).frame(width: 8, height: 8)
                Text("INDIA  ·  EARLY CAREER")
                    .font(.caption.weight(.semibold).monospaced())
                    .tracking(1.1)
                    .foregroundStyle(JobPalette.green)
            }
            Text("Your first role\nstarts somewhere.")
                .font(.system(size: 38, weight: .semibold, design: .serif))
                .tracking(-1.4)
                .lineSpacing(-2)
                .foregroundStyle(JobPalette.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text("Internships and entry-level roles, gathered from company career pages.")
                .font(.body)
                .foregroundStyle(JobPalette.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var filters: some View {
        VStack(alignment: .leading, spacing: 11) {
            JobSearchField(text: $viewModel.searchText, prompt: "Role, company or keyword", symbol: "magnifyingglass")
            JobSearchField(text: $viewModel.cityText, prompt: "Any city", symbol: "mappin.and.ellipse")
            RoleFilterChips(selectedRole: $viewModel.selectedRole, roles: JobsViewModel.roles)
        }
    }

    private var resultsHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 3) {
                Text("OPEN ROLES")
                    .font(.caption.weight(.semibold).monospaced())
                    .tracking(1)
                    .foregroundStyle(JobPalette.muted)
                Text("\(viewModel.total) opportunities")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(JobPalette.ink)
            }
            Spacer()
            if !viewModel.jobs.isEmpty {
                Text("Showing \(viewModel.jobs.count) of \(viewModel.total)")
                    .font(.caption)
                    .foregroundStyle(JobPalette.muted)
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(.top, 2)
    }

    @ViewBuilder
    private var listings: some View {
        if let errorMessage = viewModel.errorMessage, viewModel.jobs.isEmpty, !viewModel.isLoading {
            JobsEmptyState(
                title: "Couldn’t load listings",
                message: errorMessage,
                actionTitle: "Try again"
            ) {
                Task { await viewModel.refresh() }
            }
        } else if viewModel.isLoading && viewModel.jobs.isEmpty {
            VStack(spacing: 14) {
                ProgressView().tint(JobPalette.green)
                Text("Finding roles that fit…")
                    .font(.subheadline)
                    .foregroundStyle(JobPalette.muted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 46)
        } else if viewModel.jobs.isEmpty {
            JobsEmptyState(
                title: "No matching roles yet",
                message: "Try a different keyword or city, or clear the role filter.",
                actionTitle: "Clear filters"
            ) {
                viewModel.searchText = ""
                viewModel.cityText = ""
                viewModel.selectedRole = ""
            }
        } else {
            LazyVStack(spacing: 11) {
                ForEach(viewModel.jobs) { job in
                    Button {
                        selectedJob = job
                    } label: {
                        JobCard(job: job)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(job.title), \(job.company), \(job.city), \(job.role), \(job.jobType)")
                    .accessibilityHint("Shows listing details and the employer application link")
                    .onAppear {
                        guard job.id == viewModel.jobs.last?.id, viewModel.hasMore else { return }
                        Task { await viewModel.loadMore() }
                    }
                }
            }

            if viewModel.isLoadingMore {
                ProgressView("Loading more roles…")
                    .tint(JobPalette.green)
                    .font(.footnote)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 2)
            }
        }
    }
}

#Preview {
    JobsView(viewModel: JobsViewModel(preview: true))
}
