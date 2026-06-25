import SwiftUI

struct IPadRootView: View {
    @EnvironmentObject private var storage: AppStorage
    @EnvironmentObject private var workspaceViewModel: WorkspaceViewModel
    @EnvironmentObject private var libraryViewModel: LibraryViewModel
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var showSettings = false

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            LibraryView(
                viewModel: libraryViewModel,
                isSidebar: true,
                onRunPipeline: runPipeline(on:),
                onSendToWorkspace: sendToWorkspace(_:)
            )
            .navigationSplitViewColumnWidth(min: 320, ideal: 380, max: 440)
        } detail: {
            WorkspaceView(viewModel: workspaceViewModel)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .foregroundStyle(Color("AppPrimary"))
                        }
                    }
                }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView()
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") { showSettings = false }
                        }
                    }
            }
        }
    }

    private func runPipeline(on entry: ClipboardEntry) {
        workspaceViewModel.runPipelineOnSnippet(entry)
        HapticManager.completeAction()
    }

    private func sendToWorkspace(_ entry: ClipboardEntry) {
        workspaceViewModel.loadFromSnippet(entry)
        HapticManager.lightTap()
    }
}
