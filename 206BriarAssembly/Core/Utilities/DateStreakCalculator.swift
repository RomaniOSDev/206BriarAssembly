import Foundation

enum DateStreakCalculator {
    static func updatedStreak(currentStreak: Int, lastActivityDate: Date?) -> (streak: Int, lastDate: Date) {
        let today = Calendar.current.startOfDay(for: Date())
        guard let last = lastActivityDate else {
            return (1, today)
        }
        let lastDay = Calendar.current.startOfDay(for: last)
        if lastDay == today {
            return (max(currentStreak, 1), lastDay)
        }
        if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today),
           lastDay == yesterday {
            return (currentStreak + 1, today)
        }
        return (1, today)
    }
}
