import SwiftUI

enum AppTab: Int, CaseIterable {
    case home = 0
    case convert = 1
    case tools = 2
    case stats = 3
    case settings = 4

    var title: String {
        switch self {
        case .home: return "Home"
        case .convert: return "Convert"
        case .tools: return "Tools"
        case .stats: return "Stats"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .convert: return "globe"
        case .tools: return "wrench.and.screwdriver.fill"
        case .stats: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 6) {
            ForEach(AppTab.allCases, id: \.rawValue) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(
            LinearGradient(
                colors: [Color("AppSurface"), Color("AppBackground").opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
            .shadow(color: Color("AppBackground").opacity(0.65), radius: 14, y: -6)
        )
        .overlay(
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color("AppPrimary").opacity(0.35), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1),
            alignment: .top
        )
    }

    private func tabButton(_ tab: AppTab) -> some View {
        Button {
            HapticManager.lightTap()
            withAnimation(.easeOut(duration: 0.2)) {
                selection = tab
            }
        } label: {
            VStack(spacing: 5) {
                Image(systemName: tab.icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(tab.title)
                    .font(.system(size: 10, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .foregroundStyle(selection == tab ? Color("AppBackground") : Color("AppTextSecondary"))
            .frame(maxWidth: .infinity)
            .frame(minHeight: 48)
            .background {
                if selection == tab {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppGradients.primary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(AppGradients.edgeHighlight)
                        )
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(
                        selection == tab ? Color("AppAccent").opacity(0.45) : Color.clear,
                        lineWidth: 1
                    )
            )
            .appShadow(level: selection == tab ? .subtle : .none)
            .scaleEffect(selection == tab ? 1 : 0.96)
        }
        .buttonStyle(.plain)
    }
}
