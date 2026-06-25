import Foundation

struct AppBackup: Codable {
    let version: Int
    let exportDate: Date
    var clipboardHistory: [ClipboardEntry]
    var savedPipelines: [SavedPipeline]
    var activePipelineSteps: [PipelineStep]
    var regexStepConfig: RegexStepConfig?

    static let currentVersion = 3
}
