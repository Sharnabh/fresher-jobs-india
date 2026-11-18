import SwiftUI

struct RoleFilterChips: View {
    @Binding var selectedRole: String
    let roles: [String]

    private var options: [String] { ["All roles"] + roles }

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(options, id: \.self) { role in
                    let isSelected = role == "All roles" ? selectedRole.isEmpty : selectedRole == role
                    Button {
                        selectedRole = role == "All roles" ? "" : role
                    } label: {
                        Text(role)
                            .font(.subheadline.weight(isSelected ? .semibold : .medium))
                            .foregroundStyle(isSelected ? JobPalette.surface : JobPalette.ink)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(
                                isSelected ? JobPalette.green : JobPalette.surface,
                                in: Capsule()
                            )
                            .overlay {
                                Capsule().stroke(isSelected ? JobPalette.green : JobPalette.line, lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                }
            }
            .padding(.vertical, 2)
        }
        .scrollIndicators(.hidden)
        .accessibilityLabel("Filter by role")
    }
}
