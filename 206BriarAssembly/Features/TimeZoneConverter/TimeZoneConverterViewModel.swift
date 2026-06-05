import Foundation
import Combine
import AudioToolbox

final class TimeZoneConverterViewModel: ObservableObject {
    @Published var timeInput: String = ""
    @Published var resultText: String?
    @Published var errorMessage: String?
    @Published var shakeTrigger = 0
    @Published var resultScale: CGFloat = 1
    private let storage: AppStorage
    private var cancellables = Set<AnyCancellable>()

    var fromZone: String {
        get { storage.defaultFromZone }
        set { storage.defaultFromZone = newValue }
    }

    var toZone: String {
        get { storage.defaultToZone }
        set { storage.defaultToZone = newValue }
    }

    var showEmptyState: Bool {
        storage.conversionHistory.isEmpty && resultText == nil && errorMessage == nil
    }

    var conversionHistory: [ConversionRecord] {
        storage.conversionHistory
    }

    var sortedZoneIdentifiers: [String] {
        storage.sortedTimeZones(all: Self.zoneIdentifiers)
    }

    static let zoneIdentifiers: [String] = {
        let popular = [
            "UTC", "GMT",
            "America/New_York", "America/Chicago", "America/Denver", "America/Los_Angeles",
            "Europe/London", "Europe/Paris", "Europe/Berlin", "Europe/Moscow",
            "Asia/Dubai", "Asia/Kolkata", "Asia/Shanghai", "Asia/Tokyo",
            "Australia/Sydney", "Pacific/Auckland"
        ]
        let all = TimeZone.knownTimeZoneIdentifiers
        let merged = popular + all.filter { !popular.contains($0) }
        return Array(Set(merged)).sorted()
    }()

    init(storage: AppStorage) {
        self.storage = storage
        storage.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    func convert() {
        errorMessage = nil
        resultText = nil

        let trimmed = timeInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            failValidation("Enter a time in HH:MM format.")
            return
        }

        guard let (hour, minute) = parseTime(trimmed) else {
            failValidation("Enter a time in HH:MM format.")
            return
        }

        guard let from = TimeZone(identifier: fromZone),
              let to = TimeZone(identifier: toZone) else {
            failValidation("Invalid time zone selection.")
            return
        }

        var calendar = Calendar.current
        calendar.timeZone = from
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        components.second = 0

        guard let sourceDate = calendar.date(from: components) else {
            failValidation("Could not build date from input.")
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = to
        let converted = formatter.string(from: sourceDate)
        let fromLabel = displayName(for: fromZone)
        let toLabel = displayName(for: toZone)
        resultText = "\(trimmed) (\(fromLabel)) → \(converted) (\(toLabel))"

        let record = ConversionRecord(
            fromZone: fromZone,
            toZone: toZone,
            originalTime: trimmed,
            convertedTime: converted
        )
        storage.addConversionRecord(record)
        storage.recordConversionSession()

        HapticManager.mediumTap()
        AudioServicesPlaySystemSound(1057)
        resultScale = 1.15
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.resultScale = 1
        }
    }

    func toggleFavorite(_ zone: String) {
        storage.toggleFavoriteTimeZone(zone)
        HapticManager.lightTap()
    }

    func isFavorite(_ zone: String) -> Bool {
        storage.isFavoriteTimeZone(zone)
    }

    func applyHistory(_ record: ConversionRecord) {
        fromZone = record.fromZone
        toZone = record.toZone
        timeInput = record.originalTime
        convert()
    }

    func displayName(for identifier: String) -> String {
        guard let zone = TimeZone(identifier: identifier) else { return identifier }
        let formatter = DateFormatter()
        formatter.timeZone = zone
        formatter.dateFormat = "zzz"
        return "\(identifier.replacingOccurrences(of: "_", with: " ")) (\(formatter.string(from: Date())))"
    }

    private func parseTime(_ text: String) -> (Int, Int)? {
        let parts = text.split(separator: ":")
        guard parts.count == 2,
              let hour = Int(parts[0]),
              let minute = Int(parts[1]),
              hour >= 0, hour < 24,
              minute >= 0, minute < 60 else {
            return nil
        }
        return (hour, minute)
    }

    private func failValidation(_ message: String) {
        errorMessage = message
        shakeTrigger += 1
        HapticManager.warning()
    }
}
