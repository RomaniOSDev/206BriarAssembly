import SwiftUI
import Combine

struct HomeView: View {
    @EnvironmentObject private var storage: AppStorage
    @Binding var selectedTab: AppTab
    @StateObject private var viewModel: HomeViewModel
    @State private var clockDate = Date()

    init(storage: AppStorage, selectedTab: Binding<AppTab>) {
        _selectedTab = selectedTab
        _viewModel = StateObject(wrappedValue: HomeViewModel(storage: storage))
    }

    private let statColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    private let quickColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                AppScreenScroll {
                    heroSection
                    statsWidgets
                    quickActionsSection
                    featureWidgetsSection
                    progressWidget
                    activitySection
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
                clockDate = Date()
            }
        }
    }

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            Image("HomeHero")
                .resizable()
                .scaledToFill()
                .frame(height: 180)
                .frame(maxWidth: .infinity)
                .clipped()

            LinearGradient(
                colors: [Color("AppBackground").opacity(0.1), Color("AppBackground").opacity(0.92)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.greeting)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppPrimary"))
                Text("Your productivity hub")
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(Color("AppAccent"))
                    Text(clockDate, style: .time)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color("AppPrimary").opacity(0.55), Color("AppAccent").opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .appShadow(level: .raised)
    }

    private var statsWidgets: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Today at a Glance")
            LazyVGrid(columns: statColumns, spacing: 10) {
                HomeStatWidget(value: "\(viewModel.itemsCreated)", label: "Entries", icon: "square.stack.3d.up.fill")
                HomeStatWidget(value: "\(viewModel.streakDays)d", label: "Streak", icon: "flame.fill")
                HomeStatWidget(value: "\(viewModel.snippetCount)", label: "Snippets", icon: "doc.on.clipboard.fill")
                HomeStatWidget(value: "\(viewModel.conversionsRun)", label: "Sessions", icon: "bolt.fill")
            }
        }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Quick Actions")
            LazyVGrid(columns: quickColumns, spacing: 10) {
                HomeQuickActionButton(icon: "globe", title: "Convert") {
                    selectedTab = .convert
                }
                HomeQuickActionButton(icon: "doc.on.clipboard.fill", title: "Clipboard") {
                    selectedTab = .tools
                }
                HomeQuickActionButton(icon: "paintpalette.fill", title: "Colors") {
                    selectedTab = .tools
                }
                HomeQuickActionButton(icon: "text.alignleft", title: "Format") {
                    selectedTab = .tools
                }
            }
        }
    }

    private var featureWidgetsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(title: "Featured Tools")
            HStack(spacing: 12) {
                HomeFeatureWidget(
                    imageName: "HomeWidgetClipboard",
                    title: "Clipboard",
                    subtitle: "Save and organize snippets"
                ) {
                    selectedTab = .tools
                }
                HomeFeatureWidget(
                    imageName: "HomeWidgetColors",
                    title: "Color Inspector",
                    subtitle: "Hex, RGB, and HSL codes"
                ) {
                    selectedTab = .tools
                }
            }
        }
    }

    private var progressWidget: some View {
        HomeProgressWidget(
            unlocked: viewModel.unlockedAchievements,
            total: viewModel.totalAchievements
        ) {
            selectedTab = .stats
        }
    }

    private var activitySection: some View {
        AppCard(title: "Recent Activity", trailing: "Live") {
            VStack(spacing: 10) {
                if let conversion = viewModel.latestConversion {
                    HomeActivityRow(
                        icon: "globe",
                        title: "Time converted",
                        detail: "\(conversion.originalTime) → \(conversion.convertedTime)",
                        time: conversion.createdAt
                    )
                }
                if let snippet = viewModel.latestSnippet {
                    HomeActivityRow(
                        icon: "doc.text.fill",
                        title: snippet.tag,
                        detail: snippet.text,
                        time: snippet.savedAt
                    )
                }
                if let hex = viewModel.recentColorHex {
                    HomeActivityRow(
                        icon: "paintpalette.fill",
                        title: "Color inspected",
                        detail: hex
                    )
                }
                if viewModel.latestConversion == nil && viewModel.latestSnippet == nil && viewModel.recentColorHex == nil {
                    AppEmptyStateView(
                        icon: "sparkles",
                        title: "No Activity Yet",
                        message: "Use any tool to see your latest actions here."
                    )
                }
            }
        }
    }
}
