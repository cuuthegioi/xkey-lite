import SwiftUI

// MARK: - Glass Design Menu Bar Popover (macOS 12+)

struct StatusBarPopoverView: View {
    @ObservedObject var viewModel: StatusBarViewModel
    var onCheckForUpdates: (() -> Void)?
    var onDismiss: (() -> Void)?

    var body: some View {
        VStack(spacing: 4) {
            // MARK: - Toggle Vietnamese
            toggleSection

            // MARK: - Divider
            sectionDivider

            // MARK: - Footer
            footerSection
        }
        .padding(.vertical, 6)
        .frame(width: 300)
    }

    // MARK: - Toggle Section
    private var toggleSection: some View {
        HStack {
            Text("Gõ Tiếng Việt")
                .font(.system(size: 13, weight: .semibold))
            Spacer()
            Toggle("", isOn: Binding(
                get: { viewModel.isVietnameseEnabled },
                set: { _ in viewModel.toggleVietnamese() }
            ))
            .toggleStyle(.switch)
            .labelsHidden()
            .controlSize(.small)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 4)
        .menuCardStyle()
    }

    // MARK: - Footer Section
    private var footerSection: some View {
        VStack(spacing: 1) {
            ActionRow(title: "Bảng điều khiển...", icon: "gearshape", shortcut: "⌘,") {
                onDismiss?()
                viewModel.openPreferences()
            }

            Divider()
                .padding(.horizontal, 8)

            ActionRow(title: "Thoát XKey", icon: "power", shortcut: "⌘Q") {
                viewModel.quit()
            }
        }
        .menuCardStyle()
    }

    // MARK: - Section Divider
    private var sectionDivider: some View {
        Color.clear.frame(height: 0)
    }
}

// MARK: - macOS Card Style Modifier

private struct MenuCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.primary.opacity(0.05))
            )
            .padding(.horizontal, 8)
    }
}

private extension View {
    func menuCardStyle() -> some View {
        self.modifier(MenuCardModifier())
    }
}

// MARK: - Action Row (clickable row with icon, macOS style)

private struct ActionRow: View {
    let title: LocalizedStringKey
    let icon: String
    var shortcut: String? = nil
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isHovered ? .white.opacity(0.9) : .secondary)
                    .frame(width: 18)
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isHovered ? .white : .primary)
                Spacer()
                if let shortcut = shortcut {
                    Text(shortcut)
                        .font(.system(size: 11))
                        .foregroundColor(isHovered ? .white.opacity(0.7) : .secondary.opacity(0.6))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovered ? Color.accentColor : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 4)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// MARK: - NSVisualEffectView Hosting (Glass Background)

/// NSViewRepresentable wrapping NSVisualEffectView for glass/vibrancy effect
struct VisualEffectBackground: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
