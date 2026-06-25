import Foundation

enum BackupManager {
    static func makeBackup(from storage: AppStorage) -> AppBackup {
        AppBackup(
            version: AppBackup.currentVersion,
            exportDate: Date(),
            clipboardHistory: storage.clipboardHistory,
            savedPipelines: storage.savedPipelines,
            activePipelineSteps: storage.activePipelineSteps,
            regexStepConfig: storage.regexStepConfig
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
        storage.savedPipelines = backup.savedPipelines
        storage.activePipelineSteps = backup.activePipelineSteps
        if let regexStepConfig = backup.regexStepConfig {
            storage.regexStepConfig = regexStepConfig
        }
    }
}
