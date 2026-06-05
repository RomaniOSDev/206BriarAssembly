import Foundation

struct AppBackup: Codable {
    let version: Int
    let exportDate: Date
    var clipboardHistory: [ClipboardEntry]
    var conversionHistory: [ConversionRecord]
    var recentColors: [String]
    var favoriteTimeZones: [String]
    var defaultFromZone: String
    var defaultToZone: String
    var defaultFormat: String
    var itemsCreated: Int
    var conversionsRun: Int
    var streakDays: Int
    var totalMinutesUsed: Int

    static let currentVersion = 1
}
