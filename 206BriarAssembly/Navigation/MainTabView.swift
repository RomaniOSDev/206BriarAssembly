import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var storage: AppStorage
    @EnvironmentObject private var workspaceViewModel: WorkspaceViewModel
    @EnvironmentObject private var libraryViewModel: LibraryViewModel
    @EnvironmentObject private var navigationState: AppNavigationState
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                IPadRootView()
            } else {
                phoneLayout
            }
        }
        .onChange(of: navigationState.selectedSnippetID) { snippetID in
            guard let snippetID,
                  let entry = storage.clipboardHistory.first(where: { $0.id == snippetID }) else { return }
            workspaceViewModel.loadFromSnippet(entry)
            navigationState.selectedSnippetID = nil
        }
    }

    private var phoneLayout: some View {
        AppBackgroundView {
            VStack(spacing: 0) {
                tabContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                CustomTabBar(selection: $navigationState.selectedTab)
            }
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch navigationState.selectedTab {
        case .workspace:
            WorkspaceView(viewModel: workspaceViewModel)
        case .library:
            LibraryView(
                viewModel: libraryViewModel,
                onRunPipeline: { entry in
                    workspaceViewModel.runPipelineOnSnippet(entry)
                    navigationState.selectedTab = .workspace
                },
                onSendToWorkspace: { entry in
                    workspaceViewModel.loadFromSnippet(entry)
                    navigationState.selectedTab = .workspace
                }
            )
        case .settings:
            SettingsView()
        }
    }
}
