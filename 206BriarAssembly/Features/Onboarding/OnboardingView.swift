import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var storage: AppStorage
    @State private var pageIndex = 0

    private let pages: [(headline: String, description: String, imageName: String)] = [
        (
            "Build Pipelines",
            "Chain multiple text transforms and run them in one tap.",
            "OnboardingPipeline"
        ),
        (
            "Capture Snippets",
            "Save cleaned text to your library with tags and search.",
            "OnboardingLibrary"
        ),
        (
            "Reuse Presets",
            "Load saved pipelines like Clean Notes or Code Ready anytime.",
            "OnboardingPresets"
        )
    ]

    var body: some View {
        AppBackgroundView {
            VStack(spacing: 0) {
                TabView(selection: $pageIndex) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        onboardingPage(
                            index: index,
                            headline: pages[index].headline,
                            description: pages[index].description,
                            imageName: pages[index].imageName
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: pageIndex)

                footerControls
            }
        }
    }

    @ViewBuilder
    private func onboardingPage(index: Int, headline: String, description: String, imageName: String) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                Text("Step \(index + 1) of \(pages.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppBackground"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(AppGradients.primary))
                    .padding(.top, 40)

                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 280, maxHeight: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(Color("AppPrimary").opacity(0.25), lineWidth: 1)
                    )
                    .appShadow(level: .raised)

                AppCard(accent: index == pages.count - 1) {
                    VStack(spacing: 14) {
                        Text(headline)
                            .font(.largeTitle.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        Text(description)
                            .font(.body)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var footerControls: some View {
        VStack(spacing: 20) {
            HStack(spacing: 10) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(
                            index == pageIndex
                                ? AnyShapeStyle(AppGradients.primary)
                                : AnyShapeStyle(Color("AppTextSecondary").opacity(0.3))
                        )
                        .frame(width: index == pageIndex ? 32 : 8, height: 8)
                }
            }
            Button(action: advance) {
                Text(pageIndex == pages.count - 1 ? "Get Started" : "Next")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(20)
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
