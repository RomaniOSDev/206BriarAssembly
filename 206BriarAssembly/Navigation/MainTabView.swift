import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var storage: AppStorage
    @State private var selectedTab: AppTab = .home
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        AppBackgroundView {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    tabContent
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    CustomTabBar(selection: $selectedTab)
                }

                if let title = storage.pendingAchievementTitle {
                    AchievementBannerView(title: title)
                        .padding(.top, 8)
                        .zIndex(10)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
                                storage.dismissAchievementBanner()
                            }
                        }
                        .id(title)
                }
            }
        }
        .onChange(of: scenePhase) { phase in
            storage.startUsageTracking(isActive: phase == .active)
        }
        .onAppear {
            storage.startUsageTracking(isActive: scenePhase == .active)
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .home:
            HomeView(storage: storage, selectedTab: $selectedTab)
        case .convert:
            TimeZoneConverterView(storage: storage)
        case .tools:
            ToolsHubView()
        case .stats:
            AchievementsView()
        case .settings:
            SettingsView()
        }
    }
}
