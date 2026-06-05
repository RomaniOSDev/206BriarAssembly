import SwiftUI

private struct OnboardingPageData: Identifiable {
    let id: Int
    let headline: String
    let description: String
    let symbol: String
    let hints: [String]

    static let all: [OnboardingPageData] = [
        OnboardingPageData(
            id: 0,
            headline: "Get Organized",
            description: "Streamline your text manipulation tasks.",
            symbol: "square.stack.3d.up.fill",
            hints: ["Time zones", "Text tools", "Snippets"]
        ),
        OnboardingPageData(
            id: 1,
            headline: "Use Clipboard",
            description: "Automatically save and manage clipboard entries effortlessly.",
            symbol: "doc.on.clipboard.fill",
            hints: ["Save", "Tag", "Search"]
        ),
        OnboardingPageData(
            id: 2,
            headline: "Start Formatting",
            description: "Select your first text entry to begin customizing.",
            symbol: "textformat",
            hints: ["Format", "Convert", "Inspect"]
        )
    ]
}

struct OnboardingView: View {
    @EnvironmentObject private var storage: AppStorage
    @State private var pageIndex = 0

    private var pages: [OnboardingPageData] { OnboardingPageData.all }
    private var currentPage: OnboardingPageData { pages[pageIndex] }
    private var isLastPage: Bool { pageIndex == pages.count - 1 }

    var body: some View {
        AppBackgroundView {
            VStack(spacing: 0) {
                TabView(selection: $pageIndex) {
                    ForEach(pages) { page in
                        onboardingPage(page, isActive: pageIndex == page.id)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: pageIndex)

                footerControls
            }
        }
    }

    @ViewBuilder
    private func onboardingPage(_ page: OnboardingPageData, isActive: Bool) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                stepBadge(page: page)
                    .padding(.top, 20)

                OnboardingHeroIllustration(
                    symbol: page.symbol,
                    pageIndex: page.id
                )
                .padding(.vertical, 8)

                hintChips(page.hints)

                AppCard(accent: isActive && isLastPage) {
                    VStack(spacing: 14) {
                        Text(page.headline)
                            .font(.largeTitle.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)

                        Text(page.description)
                            .font(.body)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal, 20)
                .opacity(isActive ? 1 : 0.92)
                .scaleEffect(isActive ? 1 : 0.98)
                .animation(.easeOut(duration: 0.25), value: pageIndex)
            }
            .padding(.bottom, 16)
        }
    }

    private func stepBadge(page: OnboardingPageData) -> some View {
        Text("Step \(page.id + 1) of \(pages.count)")
            .font(.caption.weight(.bold))
            .foregroundStyle(Color("AppBackground"))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule().fill(AppGradients.primary)
            )
            .appShadow(level: .subtle)
    }

    private func hintChips(_ hints: [String]) -> some View {
        HStack(spacing: 8) {
            ForEach(hints, id: \.self) { hint in
                Text(hint)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(
                        Capsule().fill(AppGradients.surface)
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(Color("AppTextSecondary").opacity(0.18), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 20)
    }

    private var footerControls: some View {
        VStack(spacing: 20) {
            HStack(spacing: 10) {
                ForEach(pages) { page in
                    Capsule()
                        .fill(
                            page.id == pageIndex
                                ? AnyShapeStyle(AppGradients.primary)
                                : AnyShapeStyle(Color("AppTextSecondary").opacity(0.3))
                        )
                        .frame(width: page.id == pageIndex ? 32 : 8, height: 8)
                        .animation(.easeOut(duration: 0.25), value: pageIndex)
                }
            }

            Button(action: advance) {
                HStack(spacing: 10) {
                    Text(isLastPage ? "Get Started" : "Next")
                    Image(systemName: isLastPage ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                        .font(.body.weight(.semibold))
                }
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .appCardSurface(cornerRadius: 20, shadow: .raised)
        .padding(.horizontal, 16)
        .padding(.bottom, 28)
    }

    private func advance() {
        HapticManager.lightTap()
        if pageIndex < pages.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                pageIndex += 1
            }
        } else {
            HapticManager.completeAction()
            storage.completeOnboarding()
        }
    }
}

// MARK: - Hero illustration

private struct OnboardingHeroIllustration: View {
    let symbol: String
    let pageIndex: Int
    @State private var appeared = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("AppPrimary").opacity(0.15), lineWidth: 2)
                .frame(width: 220, height: 220)

            Circle()
                .stroke(Color("AppAccent").opacity(0.12), lineWidth: 1.5)
                .frame(width: 180, height: 180)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color("AppPrimary").opacity(0.3), Color("AppSurface").opacity(0.2)],
                        center: .center,
                        startRadius: 10,
                        endRadius: 110
                    )
                )
                .frame(width: 200, height: 200)

            decorativeOrbs

            AppIconBadge(systemName: symbol, size: 92, highlighted: true)
        }
        .frame(height: 240)
        .appShadow(level: .raised)
        .scaleEffect(appeared ? 1 : 0.82)
        .opacity(appeared ? 1 : 0)
        .onAppear { playAppearAnimation() }
        .onChange(of: pageIndex) { _ in
            appeared = false
            playAppearAnimation()
        }
    }

    @ViewBuilder
    private var decorativeOrbs: some View {
        let offsets: [(CGFloat, CGFloat)] = [(-72, -40), (78, -28), (-60, 72), (70, 64)]
        ForEach(0..<offsets.count, id: \.self) { index in
            Circle()
                .fill(
                    index % 2 == 0
                        ? Color("AppPrimary").opacity(0.35)
                        : Color("AppAccent").opacity(0.28)
                )
                .frame(width: 14, height: 14)
                .offset(x: offsets[index].0, y: offsets[index].1)
        }
    }

    private func playAppearAnimation() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
            appeared = true
        }
    }
}
