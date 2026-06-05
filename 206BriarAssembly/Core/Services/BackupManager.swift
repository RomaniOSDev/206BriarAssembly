import Foundation

enum BackupManager {
    static func makeBackup(from storage: AppStorage) -> AppBackup {
        AppBackup(
            version: AppBackup.currentVersion,
            exportDate: Date(),
            clipboardHistory: storage.clipboardHistory,
            conversionHistory: storage.conversionHistory,
            recentColors: storage.recentColors,
            favoriteTimeZones: storage.favoriteTimeZones,
            defaultFromZone: storage.defaultFromZone,
            defaultToZone: storage.defaultToZone,
            defaultFormat: storage.defaultFormat,
            itemsCreated: storage.itemsCreated,
            conversionsRun: storage.conversionsRun,
            streakDays: storage.streakDays,
            totalMinutesUsed: storage.totalMinutesUsed
        )
    }

    static func encode(_ backup: AppBackup) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(backup)
    }

    static func decode(_ data: Data) throws -> AppBackup {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(AppBackup.self, from: data)
    }

    static func apply(_ backup: AppBackup, to storage: AppStorage) {
        storage.clipboardHistory = backup.clipboardHistory
        storage.conversionHistory = backup.conversionHistory
        storage.recentColors = backup.recentColors
        storage.favoriteTimeZones = backup.favoriteTimeZones
        storage.defaultFromZone = backup.defaultFromZone
        storage.defaultToZone = backup.defaultToZone
        storage.defaultFormat = backup.defaultFormat
        storage.itemsCreated = backup.itemsCreated
        storage.conversionsRun = backup.conversionsRun
        storage.streakDays = backup.streakDays
        storage.totalMinutesUsed = backup.totalMinutesUsed
        storage.totalSessionsCompleted = backup.conversionsRun
    }
}
