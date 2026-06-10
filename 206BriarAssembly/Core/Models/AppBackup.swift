import Foundation

struct AppBackup: Codable {
    let version: Int
    let exportDate: Date
    var clipboardHistory: [ClipboardEntry]
    var savedPipelines: [SavedPipeline]
    var activePipelineSteps: [PipelineStep]

    static let currentVersion = 2
}
