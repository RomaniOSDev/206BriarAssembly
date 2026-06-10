import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var storage: AppStorage
    @State private var selectedTab: AppTab = .workspace

    var body: some View {
        AppBackgroundView {
            VStack(spacing: 0) {
                tabContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                CustomTabBar(selection: $selectedTab)
            }
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .workspace:
            WorkspaceView(storage: storage)
        case .library:
            LibraryView(storage: storage)
        case .settings:
            SettingsView()
        }
    }
}
