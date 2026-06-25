import Foundation

struct RegexStepConfig: Codable, Equatable {
    var pattern: String
    var replacement: String
    var useRegex: Bool

    static let empty = RegexStepConfig(pattern: "", replacement: "", useRegex: true)

    static let stripLogPrefix = RegexStepConfig(
        pattern: "^\\[?\\d{2}:\\d{2}(:\\d{2})?\\]?\\s*",
        replacement: "",
        useRegex: true
    )
}

struct PipelineLivePreview: Identifiable, Equatable {
    let id: Int
    let step: PipelineStep
    let output: String

    var previewSnippet: String {
        let trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count <= 120 { return trimmed }
        return String(trimmed.prefix(120)) + "…"
    }
}
