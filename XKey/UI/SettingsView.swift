//
//  SettingsView.swift
//  XKey
//
//  Unified Settings View with Apple-style sidebar navigation
//  Supports macOS 26 Tahoe Liquid Glass design
//  Uses shared components from SettingsSections/
//

import SwiftUI

// MARK: - Settings Section

enum SettingsSection: String, CaseIterable, Identifiable {
    case general = "Cơ bản"
    case advanced = "Nâng cao"
    case inputSources = "Input Sources"
    case about = "Giới thiệu"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .general: return "gearshape"
        case .advanced: return "slider.horizontal.3"
        case .inputSources: return "globe"
        case .about: return "info.circle"
        }
    }
}

// MARK: - Settings Navigator

/// Single source of truth for the active section, shared between the window
/// controller and the view so sections can be switched live without recreating the window.
final class SettingsNavigator: ObservableObject {
    @Published var selectedSection: SettingsSection

    init(_ selectedSection: SettingsSection = .general) {
        self.selectedSection = selectedSection
    }
}

// MARK: - Main Settings View

@available(macOS 13.0, *)
struct SettingsView: View {
    @StateObject private var viewModel = PreferencesViewModel()
    @ObservedObject var navigator: SettingsNavigator

    var onSave: ((Preferences) -> Void)?

    init(navigator: SettingsNavigator, onSave: ((Preferences) -> Void)? = nil) {
        self.navigator = navigator
        self.onSave = onSave
    }

    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(SettingsSection.allCases, selection: $navigator.selectedSection) { section in
                Label {
                    Text(LocalizedStringKey(section.rawValue))
                } icon: {
                    Image(systemName: section.icon)
                }
                    .tag(section)
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 220)
        } detail: {
            // Content - Using shared components
            Group {
                switch navigator.selectedSection {
                case .general:
                    GeneralSection(viewModel: viewModel)
                case .advanced:
                    AdvancedSection(viewModel: viewModel)
                case .inputSources:
                    InputSourcesSection(preferencesViewModel: viewModel)
                case .about:
                    AboutSection()
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

// MARK: - Preview

@available(macOS 13.0, *)
#Preview {
    SettingsView(navigator: SettingsNavigator())
}
