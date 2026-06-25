import Foundation

enum PipelineStep: String, Codable, CaseIterable, Identifiable {
    case trim
    case collapseSpaces
    case uppercase
    case lowercase
    case dedupeLines
    case sortLines
    case numberLines
    case snakeCase
    case camelCase
    case kebabCase
    case titleCase
    case regexReplace

    var id: String { rawValue }

    var title: String {
        switch self {
        case .trim: return "Trim"
        case .collapseSpaces: return "Collapse Spaces"
        case .uppercase: return "Uppercase"
        case .lowercase: return "Lowercase"
        case .dedupeLines: return "Dedupe Lines"
        case .sortLines: return "Sort Lines"
        case .numberLines: return "Number Lines"
        case .snakeCase: return "snake_case"
        case .camelCase: return "camelCase"
        case .kebabCase: return "kebab-case"
        case .titleCase: return "Title Case"
        case .regexReplace: return "Regex Replace"
        }
    }

    var icon: String {
        switch self {
        case .trim: return "scissors"
        case .collapseSpaces: return "text.justify"
        case .uppercase: return "textformat.size.larger"
        case .lowercase: return "textformat.size.smaller"
        case .dedupeLines: return "line.3.horizontal.decrease"
        case .sortLines: return "arrow.up.arrow.down"
        case .numberLines: return "list.number"
        case .snakeCase: return "textformat.abc"
        case .camelCase: return "textformat"
        case .kebabCase: return "text.word.spacing"
        case .titleCase: return "textformat.size"
        case .regexReplace: return "text.magnifyingglass"
        }
    }

    var requiresRegexConfig: Bool {
        self == .regexReplace
    }
}

struct SavedPipeline: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var steps: [PipelineStep]
    var regexConfig: RegexStepConfig?

    init(id: UUID = UUID(), name: String, steps: [PipelineStep], regexConfig: RegexStepConfig? = nil) {
        self.id = id
        self.name = name
        self.steps = steps
        self.regexConfig = regexConfig
    }
}

enum PipelinePreset {
    static let logCleaner: SavedPipeline = SavedPipeline(
        name: "Log Cleaner",
        steps: [.trim, .dedupeLines, .collapseSpaces]
    )
    static let stripTimestamps: SavedPipeline = SavedPipeline(
        name: "Strip Timestamps",
        steps: [.regexReplace, .trim, .dedupeLines],
        regexConfig: .stripLogPrefix
    )
    static let apiKeysFormat: SavedPipeline = SavedPipeline(
        name: "API Keys Format",
        steps: [.trim, .dedupeLines, .snakeCase]
    )

    static let all: [SavedPipeline] = [logCleaner, stripTimestamps, apiKeysFormat]

    static let cleanNotes: SavedPipeline = logCleaner
}
