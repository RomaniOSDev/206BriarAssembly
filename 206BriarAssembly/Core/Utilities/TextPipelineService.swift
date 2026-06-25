import Foundation

enum TextPipelineService {
    static func run(
        steps: [PipelineStep],
        on text: String,
        regexConfig: RegexStepConfig = .empty
    ) -> String {
        livePreviews(steps: steps, on: text, regexConfig: regexConfig).last?.output ?? text
    }

    static func livePreviews(
        steps: [PipelineStep],
        on text: String,
        regexConfig: RegexStepConfig = .empty
    ) -> [PipelineLivePreview] {
        var current = text
        var previews: [PipelineLivePreview] = []
        for (index, step) in steps.enumerated() {
            current = apply(step, to: current, regexConfig: regexConfig)
            previews.append(PipelineLivePreview(id: index, step: step, output: current))
        }
        return previews
    }

    static func apply(
        _ step: PipelineStep,
        to text: String,
        regexConfig: RegexStepConfig = .empty
    ) -> String {
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
        case .regexReplace:
            guard !regexConfig.pattern.isEmpty else { return text }
            switch TextProcessingService.previewReplace(
                in: text,
                find: regexConfig.pattern,
                replacement: regexConfig.replacement,
                useRegex: regexConfig.useRegex
            ) {
            case .success(let result):
                return result
            case .failure:
                return text
            }
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
