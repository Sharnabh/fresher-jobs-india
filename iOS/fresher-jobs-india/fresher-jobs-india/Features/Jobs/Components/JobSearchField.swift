import SwiftUI

struct JobSearchField: View {
    @Binding var text: String
    let prompt: String
    let symbol: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(JobPalette.muted)
                .accessibilityHidden(true)
            TextField(prompt, text: $text)
                .font(.body)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(JobPalette.muted.opacity(0.7))
                }
                .accessibilityLabel("Clear \(prompt.lowercased())")
            }
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 48)
        .background(JobPalette.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(JobPalette.line, lineWidth: 1)
        }
    }
}
