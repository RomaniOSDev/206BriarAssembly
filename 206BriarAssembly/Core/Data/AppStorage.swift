import Foundation
import Combine
import AudioToolbox

final class AppStorage: ObservableObject {
    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalSessionsCompleted = "totalSessionsCompleted"
        static let totalMinutesUsed = "totalMinutesUsed"
        static let streakDays = "streakDays"
        static let lastActivityDate = "lastActivityDate"
        static let achievementsUnlocked = "achievementsUnlocked"
        static let itemsCreated = "itemsCreated"
        static let clipboardEntries = "clipboardEntries"
        static let conversionsRun = "conversionsRun"
        static let defaultFromZone = "defaultFromZone"
        static let defaultToZone = "defaultToZone"
        static let lastConvertedTime = "lastConvertedTime"
        static let conversionHistory = "conversionHistory"
        static let clipboardHistory = "clipboardHistory"
        static let lastSavedDate = "lastSavedDate"
        static let recentColors = "recentColors"
        static let defaultFormat = "defaultFormat"
        static let favoriteTimeZones = "favoriteTimeZones"
        static let sessionStartTimestamp = "sessionStartTimestamp"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var totalSessionsCompleted: Int {
        didSet { defaults.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted) }
    }

    @Published var totalMinutesUsed: Int {
        didSet { defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed) }
    }

    @Published var streakDays: Int {
        didSet { defaults.set(streakDays, forKey: Keys.streakDays) }
    }

    @Published var lastActivityDate: Date? {
        didSet {
            if let date = lastActivityDate {
                defaults.set(date, forKey: Keys.lastActivityDate)
            } else {
                defaults.removeObject(forKey: Keys.lastActivityDate)
            }
        }
    }

    @Published var achievementsUnlocked: [String: Date] {
        didSet { saveAchievements() }
    }

    @Published var itemsCreated: Int {
        didSet { defaults.set(itemsCreated, forKey: Keys.itemsCreated) }
    }

    @Published var clipboardEntries: Int {
        didSet { defaults.set(clipboardEntries, forKey: Keys.clipboardEntries) }
    }

    @Published var conversionsRun: Int {
        didSet { defaults.set(conversionsRun, forKey: Keys.conversionsRun) }
    }

    @Published var defaultFromZone: String {
        didSet { defaults.set(defaultFromZone, forKey: Keys.defaultFromZone) }
    }

    @Published var defaultToZone: String {
        didSet { defaults.set(defaultToZone, forKey: Keys.defaultToZone) }
    }

    @Published var lastConvertedTime: Date? {
        didSet {
            if let date = lastConvertedTime {
                defaults.set(date, forKey: Keys.lastConvertedTime)
            } else {
                defaults.removeObject(forKey: Keys.lastConvertedTime)
            }
        }
    }

    @Published var conversionHistory: [ConversionRecord] {
        didSet { saveConversionHistory() }
    }

    @Published var clipboardHistory: [ClipboardEntry] {
        didSet {
            saveClipboardHistory()
            clipboardEntries = clipboardHistory.count
        }
    }

    @Published var lastSavedDate: Date? {
        didSet {
            if let date = lastSavedDate {
                defaults.set(date, forKey: Keys.lastSavedDate)
            } else {
                defaults.removeObject(forKey: Keys.lastSavedDate)
            }
        }
    }

    @Published var recentColors: [String] {
        didSet { defaults.set(recentColors, forKey: Keys.recentColors) }
    }

    @Published var defaultFormat: String {
        didSet { defaults.set(defaultFormat, forKey: Keys.defaultFormat) }
    }

    @Published var favoriteTimeZones: [String] {
        didSet { defaults.set(favoriteTimeZones, forKey: Keys.favoriteTimeZones) }
    }

    @Published var pendingAchievementTitle: String?
    private var achievementBannerQueue: [String] = []

    private var cancellables = Set<AnyCancellable>()
    private var minuteTimerCancellable: AnyCancellable?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.loadAchievements(from: defaults)
        itemsCreated = defaults.integer(forKey: Keys.itemsCreated)
        clipboardEntries = defaults.integer(forKey: Keys.clipboardEntries)
        conversionsRun = defaults.integer(forKey: Keys.conversionsRun)

        let localZone = TimeZone.current.identifier
        defaultFromZone = defaults.string(forKey: Keys.defaultFromZone) ?? localZone
        defaultToZone = defaults.string(forKey: Keys.defaultToZone) ?? "UTC"
        lastConvertedTime = defaults.object(forKey: Keys.lastConvertedTime) as? Date
        conversionHistory = Self.loadJSON([ConversionRecord].self, key: Keys.conversionHistory, defaults: defaults) ?? []
        clipboardHistory = Self.loadJSON([ClipboardEntry].self, key: Keys.clipboardHistory, defaults: defaults) ?? []
        lastSavedDate = defaults.object(forKey: Keys.lastSavedDate) as? Date
        recentColors = defaults.stringArray(forKey: Keys.recentColors) ?? []
        defaultFormat = defaults.string(forKey: Keys.defaultFormat) ?? "Hex"
        favoriteTimeZones = defaults.stringArray(forKey: Keys.favoriteTimeZones) ?? []

        if clipboardEntries == 0 {
            clipboardEntries = clipboardHistory.count
        }

        NotificationCenter.default.publisher(for: .dataReset)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reloadFromDefaults()
            }
            .store(in: &cancellables)
    }

    func completeOnboarding() {
        hasSeenOnboarding = true
    }

    func recordMeaningfulAction(incrementItem: Bool = true, incrementConversion: Bool = false) {
        let streakUpdate = DateStreakCalculator.updatedStreak(
            currentStreak: streakDays,
            lastActivityDate: lastActivityDate
        )
        streakDays = streakUpdate.streak
        lastActivityDate = streakUpdate.lastDate

        if incrementItem {
            itemsCreated += 1
        }
        if incrementConversion {
            conversionsRun += 1
            totalSessionsCompleted = conversionsRun
        }

        checkAchievements()
    }

    func recordConversionSession() {
        recordMeaningfulAction(incrementItem: true, incrementConversion: true)
    }

    func recordClipboardSave() {
        recordMeaningfulAction(incrementItem: true, incrementConversion: false)
    }

    func recordColorInspection() {
        recordMeaningfulAction(incrementItem: true, incrementConversion: true)
    }

    func recordTextToolUse() {
        recordMeaningfulAction(incrementItem: true, incrementConversion: false)
    }

    func toggleFavoriteTimeZone(_ zone: String) {
        if let index = favoriteTimeZones.firstIndex(of: zone) {
            favoriteTimeZones.remove(at: index)
        } else {
            favoriteTimeZones.append(zone)
        }
    }

    func isFavoriteTimeZone(_ zone: String) -> Bool {
        favoriteTimeZones.contains(zone)
    }

    func sortedTimeZones(all: [String]) -> [String] {
        let favorites = favoriteTimeZones.filter { all.contains($0) }
        let rest = all.filter { !favoriteTimeZones.contains($0) }
        return favorites + rest
    }

    var clipboardTags: [String] {
        let tags = Set(clipboardHistory.map(\.tag))
        return ["All"] + tags.sorted()
    }

    func addConversionRecord(_ record: ConversionRecord) {
        conversionHistory.insert(record, at: 0)
        if conversionHistory.count > 50 {
            conversionHistory = Array(conversionHistory.prefix(50))
        }
        lastConvertedTime = record.createdAt
    }

    func addClipboardEntry(_ entry: ClipboardEntry) {
        clipboardHistory.insert(entry, at: 0)
        lastSavedDate = entry.savedAt
    }

    func updateClipboardEntry(_ entry: ClipboardEntry) {
        if let index = clipboardHistory.firstIndex(where: { $0.id == entry.id }) {
            clipboardHistory[index] = entry
        }
    }

    func deleteClipboardEntry(id: UUID) {
        clipboardHistory.removeAll { $0.id == id }
    }

    func addRecentColor(_ hex: String) {
        var updated = recentColors.filter { $0 != hex }
        updated.insert(hex, at: 0)
        recentColors = Array(updated.prefix(20))
    }

    func exportBackupData() throws -> Data {
        try BackupManager.encode(BackupManager.makeBackup(from: self))
    }

    func importBackupData(_ data: Data) throws {
        let backup = try BackupManager.decode(data)
        BackupManager.apply(backup, to: self)
    }

    func startUsageTracking(isActive: Bool) {
        minuteTimerCancellable?.cancel()
        guard isActive else { return }
        minuteTimerCancellable = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.totalMinutesUsed += 1
            }
    }

    func resetAllData() {
        let keys = [
            Keys.hasSeenOnboarding, Keys.totalSessionsCompleted, Keys.totalMinutesUsed,
            Keys.streakDays, Keys.lastActivityDate, Keys.achievementsUnlocked,
            Keys.itemsCreated, Keys.clipboardEntries, Keys.conversionsRun,
            Keys.defaultFromZone, Keys.defaultToZone, Keys.lastConvertedTime,
            Keys.conversionHistory, Keys.clipboardHistory, Keys.lastSavedDate,
            Keys.recentColors, Keys.defaultFormat, Keys.favoriteTimeZones,
            Keys.sessionStartTimestamp
        ]
        keys.forEach { defaults.removeObject(forKey: $0) }
        defaults.synchronize()
        reloadFromDefaults()
        defaultFromZone = TimeZone.current.identifier
        defaultToZone = "UTC"
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    private func reloadFromDefaults() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.loadAchievements(from: defaults)
        itemsCreated = defaults.integer(forKey: Keys.itemsCreated)
        clipboardEntries = defaults.integer(forKey: Keys.clipboardEntries)
        conversionsRun = defaults.integer(forKey: Keys.conversionsRun)
        defaultFromZone = defaults.string(forKey: Keys.defaultFromZone) ?? TimeZone.current.identifier
        defaultToZone = defaults.string(forKey: Keys.defaultToZone) ?? "UTC"
        lastConvertedTime = defaults.object(forKey: Keys.lastConvertedTime) as? Date
        conversionHistory = Self.loadJSON([ConversionRecord].self, key: Keys.conversionHistory, defaults: defaults) ?? []
        clipboardHistory = Self.loadJSON([ClipboardEntry].self, key: Keys.clipboardHistory, defaults: defaults) ?? []
        lastSavedDate = defaults.object(forKey: Keys.lastSavedDate) as? Date
        recentColors = defaults.stringArray(forKey: Keys.recentColors) ?? []
        defaultFormat = defaults.string(forKey: Keys.defaultFormat) ?? "Hex"
        favoriteTimeZones = defaults.stringArray(forKey: Keys.favoriteTimeZones) ?? []
        pendingAchievementTitle = nil
        achievementBannerQueue = []
    }

    private func checkAchievements() {
        for achievement in AchievementDefinition.all {
            guard achievementsUnlocked[achievement.id] == nil else { continue }
            guard achievement.isUnlocked(self) else { continue }
            achievementsUnlocked[achievement.id] = Date()
            queueAchievementBanner(title: achievement.title)
            HapticManager.success()
            AudioServicesPlaySystemSound(1057)
        }
    }

    private func queueAchievementBanner(title: String) {
        if pendingAchievementTitle == nil {
            pendingAchievementTitle = title
        } else {
            achievementBannerQueue.append(title)
        }
    }

    func dismissAchievementBanner() {
        if achievementBannerQueue.isEmpty {
            pendingAchievementTitle = nil
        } else {
            pendingAchievementTitle = achievementBannerQueue.removeFirst()
        }
    }

    private func saveAchievements() {
        if let data = try? encoder.encode(achievementsUnlocked) {
            defaults.set(data, forKey: Keys.achievementsUnlocked)
        }
    }

    private func saveConversionHistory() {
        if let data = try? encoder.encode(conversionHistory) {
            defaults.set(data, forKey: Keys.conversionHistory)
        }
    }

    private func saveClipboardHistory() {
        if let data = try? encoder.encode(clipboardHistory) {
            defaults.set(data, forKey: Keys.clipboardHistory)
        }
    }

    private static func loadAchievements(from defaults: UserDefaults) -> [String: Date] {
        guard let data = defaults.data(forKey: Keys.achievementsUnlocked),
              let decoded = try? JSONDecoder().decode([String: Date].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private static func loadJSON<T: Decodable>(
        _ type: T.Type,
        key: String,
        defaults: UserDefaults
    ) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
