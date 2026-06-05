import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var storage: AppStorage

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var unlockedCount: Int {
        AchievementDefinition.all.filter {
            $0.isUnlocked(storage) || storage.achievementsUnlocked[$0.id] != nil
        }.count
    }

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                AppScreenScroll {
                    AppCard(title: "Summary", trailing: "\(unlockedCount)/\(AchievementDefinition.all.count)") {
                        HStack(spacing: 10) {
                            AppMetricTile(value: "\(storage.itemsCreated)", label: "Items", icon: "square.stack.3d.up.fill")
                            AppMetricTile(value: "\(storage.conversionsRun)", label: "Sessions", icon: "bolt.fill")
                            AppMetricTile(value: "\(storage.streakDays)", label: "Streak", icon: "flame.fill")
                        }
                    }

                    AppSectionHeader(title: "Badges")
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(AchievementDefinition.all) { achievement in
                            achievementBadge(achievement)
                        }
                    }
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func achievementBadge(_ achievement: AchievementDefinition) -> some View {
        let unlocked = achievement.isUnlocked(storage) || storage.achievementsUnlocked[achievement.id] != nil
        return VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(unlocked ? Color("AppPrimary").opacity(0.2) : Color("AppBackground"))
                    .frame(width: 52, height: 52)
                Image(systemName: unlocked ? "star.fill" : "star")
                    .font(.title2)
                    .foregroundStyle(unlocked ? Color("AppPrimary") : Color("AppTextSecondary"))
            }
            Text(achievement.title)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
            Text(achievement.description)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
        }
        .padding(14)
        .frame(minHeight: 130)
        .frame(maxWidth: .infinity)
        .appCardSurface(cornerRadius: 16, accent: unlocked, shadow: .none)
        .opacity(unlocked ? 1 : 0.72)
    }
}
