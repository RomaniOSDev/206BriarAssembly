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
        }
    }
}

struct SavedPipeline: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var steps: [PipelineStep]

    init(id: UUID = UUID(), name: String, steps: [PipelineStep]) {
        self.id = id
        self.name = name
        self.steps = steps
    }
}

enum PipelinePreset {
    static let cleanNotes: SavedPipeline = SavedPipeline(
        name: "Clean Notes",
        steps: [.trim, .collapseSpaces, .dedupeLines]
    )
    static let codeReady: SavedPipeline = SavedPipeline(
        name: "Code Ready",
        steps: [.trim, .dedupeLines, .snakeCase]
    )
    static let listFormat: SavedPipeline = SavedPipeline(
        name: "List Format",
        steps: [.trim, .sortLines, .numberLines]
    )

    static let all: [SavedPipeline] = [cleanNotes, codeReady, listFormat]
}
