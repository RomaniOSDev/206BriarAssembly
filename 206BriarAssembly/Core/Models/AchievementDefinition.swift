import Foundation

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let isUnlocked: (AppStorage) -> Bool

    static let all: [AchievementDefinition] = [
        AchievementDefinition(
            id: "first_entry",
            title: "First Entry",
            description: "Created your first formatted item.",
            isUnlocked: { $0.itemsCreated >= 1 }
        ),
        AchievementDefinition(
            id: "clipboard_saver",
            title: "Clipboard Saver",
            description: "Saved five different clipboard entries.",
            isUnlocked: { $0.clipboardEntries >= 5 }
        ),
        AchievementDefinition(
            id: "frequent_formatter",
            title: "Frequent Formatter",
            description: "Formatted ten text items.",
            isUnlocked: { $0.itemsCreated >= 10 }
        ),
        AchievementDefinition(
            id: "quick_converter",
            title: "Quick Converter",
            description: "Performed fifty conversions.",
            isUnlocked: { $0.conversionsRun >= 50 }
        ),
        AchievementDefinition(
            id: "power_user",
            title: "Power User",
            description: "Reached 50 items.",
            isUnlocked: { $0.itemsCreated >= 50 }
        ),
        AchievementDefinition(
            id: "active_user",
            title: "Active User",
            description: "Completed 10 sessions.",
            isUnlocked: { $0.conversionsRun >= 10 }
        ),
        AchievementDefinition(
            id: "dedicated_user",
            title: "Dedicated User",
            description: "Completed 50 sessions.",
            isUnlocked: { $0.conversionsRun >= 50 }
        ),
        AchievementDefinition(
            id: "three_day_streak",
            title: "Three-Day Streak",
            description: "Used the app 3 days in a row.",
            isUnlocked: { $0.streakDays >= 3 }
        )
    ]
}
