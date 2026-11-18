import SwiftUI

struct JobDetailView: View {
    let job: Job

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(String(job.company.prefix(1)).uppercased())
                        .font(.title2.weight(.bold))
                        .foregroundStyle(JobPalette.green)
                        .frame(width: 54, height: 54)
                        .background(JobPalette.paleGreen, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .accessibilityHidden(true)
                    Text(job.title)
                        .font(.largeTitle.weight(.semibold))
                        .foregroundStyle(JobPalette.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("\(job.company)  ·  \(job.city)")
                        .font(.body)
                        .foregroundStyle(JobPalette.muted)
                    HStack(spacing: 8) {
                        DetailTag(title: job.role)
                        DetailTag(title: job.jobType)
                    }
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text("APPLY AT THE SOURCE")
                        .font(.caption.weight(.semibold).monospaced())
                        .tracking(0.8)
                        .foregroundStyle(JobPalette.muted)
                    Text("The full job description and application form are on the employer’s career site. Review the experience requirements there before applying.")
                        .font(.body)
                        .foregroundStyle(JobPalette.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(17)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(JobPalette.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay { RoundedRectangle(cornerRadius: 18).stroke(JobPalette.line, lineWidth: 1) }

                Link(destination: job.sourceURL) {
                    HStack {
                        Text("View on company site")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                    }
                    .font(.headline)
                    .foregroundStyle(JobPalette.surface)
                    .padding(.horizontal, 18)
                    .frame(minHeight: 54)
                    .background(JobPalette.green, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .accessibilityHint("Opens the original job posting in your browser")
            }
            .padding(22)
            .frame(maxWidth: 620, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(JobPalette.canvas.ignoresSafeArea())
        .scrollIndicators(.hidden)
    }
}

private struct DetailTag: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(JobPalette.green)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(JobPalette.paleGreen, in: Capsule())
    }
}
