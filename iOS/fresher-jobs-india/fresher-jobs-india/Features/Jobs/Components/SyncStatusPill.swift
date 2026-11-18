import SwiftUI

struct SyncStatusPill: View {
    let status: SyncStatusResponse?

    private var isSyncing: Bool { status?.syncing == true }

    var body: some View {
        HStack(spacing: 7) {
            if isSyncing {
                ProgressView().controlSize(.mini).tint(JobPalette.green)
            } else {
                Circle()
                    .fill(status == nil ? JobPalette.muted : JobPalette.green)
                    .frame(width: 7, height: 7)
            }
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(JobPalette.muted)
                .lineLimit(1)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 7)
        .background(JobPalette.surface.opacity(0.85), in: Capsule())
        .accessibilityElement(children: .combine)
    }

    private var label: String {
        if isSyncing { return "Checking \(status?.configuredBoards ?? 0) boards" }
        if let count = status?.activeJobs { return "\(count) open roles" }
        return "Connecting"
    }
}
