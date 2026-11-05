//
//  PreferencesView.swift
//  XKey
//
//  SwiftUI Preferences View with Vertical Sidebar Layout
//  Uses shared components from SettingsSections/
//  Compatible with macOS 12+
//

import SwiftUI

// MARK: - Section Enum

/// Sections for the legacy preferences view (macOS 12 compatible)
enum PreferencesSection: String, CaseIterable, Identifiable {
    case about = "Giới thiệu"
    case general = "Cơ bản"
    case advanced = "Nâng cao"
    case inputSources = "Input Sources"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .about: return "info.circle"
        case .general: return "gearshape"
        case .advanced: return "slider.horizontal.3"
        case .inputSources: return "globe"
        }
    }

    /// Whether this section is available on the current macOS version
    var isAvailable: Bool {
        return true
    }

    /// Map from legacy integer tab index to section
    static func from(tabIndex: Int) -> PreferencesSection {
        switch tabIndex {
        case 0: return .about
        case 1: return .general
        case 3: return .advanced
        case 4: return .inputSources
        default: return .general
        }
    }
}

// MARK: - Preferences Navigator

/// Single source of truth for the active section, shared between the window
/// controller and the view so sections can be switched live without recreating the window.
final class PreferencesNavigator: ObservableObject {
    @Published var selectedSection: PreferencesSection

    init(_ selectedSection: PreferencesSection = .general) {
        self.selectedSection = selectedSection
    }
}

// MARK: - Preferences View

struct PreferencesView: View {
    @StateObject private var viewModel = PreferencesViewModel()
    @ObservedObject var navigator: PreferencesNavigator

    var onSave: ((Preferences) -> Void)?

    init(navigator: PreferencesNavigator, onSave: ((Preferences) -> Void)? = nil) {
        self.navigator = navigator
        self.onSave = onSave
    }

    var body: some View {
        // Sidebar + Content layout
        HStack(spacing: 0) {
            // Vertical sidebar
            ScrollView {
                VStack(spacing: 2) {
                    ForEach(PreferencesSection.allCases.filter { $0.isAvailable }) { section in
                        SidebarButton(
                            title: LocalizedStringKey(section.rawValue),
                            icon: section.icon,
                            isSelected: navigator.selectedSection == section
                        ) {
                            navigator.selectedSection = section
                        }
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 6)
            }
            .frame(width: 160)
            .background(Color(NSColor.windowBackgroundColor).opacity(0.5))

            Divider()

            // Content area
            Group {
                switch navigator.selectedSection {
                case .about:
                    AboutSection()
                case .general:
                    GeneralSection(viewModel: viewModel)
                case .advanced:
                    AdvancedSection(viewModel: viewModel)
                case .inputSources:
                    InputSourcesSection(preferencesViewModel: viewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(width: 750, height: 550)
        .onReceive(viewModel.objectWillChange) { _ in
            // Auto-save when any preference changes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                viewModel.save()
                onSave?(viewModel.preferences)
            }
        }
    }
}

// MARK: - Sidebar Button

/// Custom sidebar button compatible with macOS 12+
private struct SidebarButton: View {
    let title: LocalizedStringKey
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .frame(width: 20)
                    .foregroundColor(isSelected ? .white : .secondary)

                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(isSelected ? .white : .primary)

                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color.accentColor : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    PreferencesView(navigator: PreferencesNavigator())
}
