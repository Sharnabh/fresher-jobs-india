import SwiftUI

struct JobCard: View {
    let job: Job

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 13) {
                Text(String(job.company.prefix(1)).uppercased())
                    .font(.title3.weight(.bold))
                    .foregroundStyle(JobPalette.green)
                    .frame(width: 46, height: 46)
                    .background(JobPalette.paleGreen, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 5) {
                    Text(job.title)
                        .font(.headline)
                        .foregroundStyle(JobPalette.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("\(job.company)  ·  \(job.city)")
                        .font(.subheadline)
                        .foregroundStyle(JobPalette.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 2)
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(JobPalette.muted)
                    .padding(.top, 4)
                    .accessibilityHidden(true)
            }

            HStack(spacing: 7) {
                JobTag(title: job.role, prominent: true)
                JobTag(title: job.jobType, prominent: false)
                Spacer(minLength: 0)
                if let postedAt = job.postedDate {
                    Text(postedAt.formatted(.relative(presentation: .named)))
                        .font(.caption)
                        .foregroundStyle(JobPalette.muted)
                        .lineLimit(1)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(JobPalette.surface, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(JobPalette.line.opacity(0.8), lineWidth: 1)
        }
    }
}

private struct JobTag: View {
    let title: String
    let prominent: Bool

    var body: some View {
        Text(title)
            .font(.caption.weight(.medium))
            .foregroundStyle(prominent ? JobPalette.green : JobPalette.muted)
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(prominent ? JobPalette.paleGreen : JobPalette.canvas, in: Capsule())
            .lineLimit(1)
    }
}
