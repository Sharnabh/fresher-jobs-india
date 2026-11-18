import SwiftUI

struct JobsEmptyState: View {
    let title: String
    let message: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "sparkle.magnifyingglass")
                .font(.system(size: 28, weight: .regular))
                .foregroundStyle(JobPalette.green)
                .frame(width: 68, height: 68)
                .background(JobPalette.paleGreen, in: Circle())
                .accessibilityHidden(true)
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(JobPalette.ink)
                .multilineTextAlignment(.center)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(JobPalette.muted)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Button(actionTitle, action: action)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(JobPalette.surface)
                .padding(.horizontal, 18)
                .padding(.vertical, 11)
                .background(JobPalette.green, in: Capsule())
                .padding(.top, 3)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 36)
        .background(JobPalette.surface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(JobPalette.line, lineWidth: 1)
        }
    }
}
