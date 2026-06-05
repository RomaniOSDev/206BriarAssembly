import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    private let storage: AppStorage
    private var cancellables = Set<AnyCancellable>()

    init(storage: AppStorage) {
        self.storage = storage
        storage.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }

    var itemsCreated: Int { storage.itemsCreated }
    var streakDays: Int { storage.streakDays }
    var snippetCount: Int { storage.clipboardHistory.count }
    var conversionsRun: Int { storage.conversionsRun }

    var unlockedAchievements: Int {
        AchievementDefinition.all.filter {
            $0.isUnlocked(storage) || storage.achievementsUnlocked[$0.id] != nil
        }.count
    }

    var totalAchievements: Int { AchievementDefinition.all.count }

    var latestSnippet: ClipboardEntry? {
        storage.clipboardHistory.first
    }

    var latestConversion: ConversionRecord? {
        storage.conversionHistory.first
    }

    var recentColorHex: String? {
        storage.recentColors.first
    }
}
