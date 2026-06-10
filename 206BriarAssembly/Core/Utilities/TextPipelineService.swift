import Foundation

enum TextPipelineService {
    static func run(steps: [PipelineStep], on text: String) -> String {
        steps.reduce(text) { current, step in
            apply(step, to: current)
        }
    }

    static func apply(_ step: PipelineStep, to text: String) -> String {
        switch step {
        case .trim, .collapseSpaces, .uppercase, .lowercase, .numberLines, .sortLines, .dedupeLines:
            guard let action = formatterAction(for: step) else { return text }
            return TextProcessingService.apply(action, to: text)
        case .snakeCase:
            return TextProcessingService.convertCase(.snakeCase, input: text)
        case .camelCase:
            return TextProcessingService.convertCase(.camelCase, input: text)
        case .kebabCase:
            return TextProcessingService.convertCase(.kebabCase, input: text)
        case .titleCase:
            return TextProcessingService.convertCase(.titleCase, input: text)
        }
    }

    private static func formatterAction(for step: PipelineStep) -> TextFormatterAction? {
        switch step {
        case .trim: return .trim
        case .collapseSpaces: return .collapseSpaces
        case .uppercase: return .uppercase
        case .lowercase: return .lowercase
        case .numberLines: return .numberLines
        case .sortLines: return .sortLines
        case .dedupeLines: return .dedupeLines
        default: return nil
        }
    }
}
