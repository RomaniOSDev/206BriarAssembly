import Foundation

enum TextProcessingError: LocalizedError {
    case emptyFind
    case invalidRegex

    var errorDescription: String? {
        switch self {
        case .emptyFind: return "Enter text to find."
        case .invalidRegex: return "Invalid regular expression."
        }
    }
}

enum TextFormatterAction: String, CaseIterable, Identifiable {
    case trim
    case uppercase
    case lowercase
    case collapseSpaces
    case numberLines
    case sortLines
    case dedupeLines

    var id: String { rawValue }

    var title: String {
        switch self {
        case .trim: return "Trim"
        case .uppercase: return "Uppercase"
        case .lowercase: return "Lowercase"
        case .collapseSpaces: return "Collapse Spaces"
        case .numberLines: return "Number Lines"
        case .sortLines: return "Sort Lines"
        case .dedupeLines: return "Dedupe Lines"
        }
    }

    var icon: String {
        switch self {
        case .trim: return "scissors"
        case .uppercase: return "textformat.size.larger"
        case .lowercase: return "textformat.size.smaller"
        case .collapseSpaces: return "text.justify"
        case .numberLines: return "list.number"
        case .sortLines: return "arrow.up.arrow.down"
        case .dedupeLines: return "line.3.horizontal.decrease"
        }
    }
}

enum CaseNamingStyle: String, CaseIterable, Identifiable {
    case camelCase
    case snakeCase
    case kebabCase
    case titleCase

    var id: String { rawValue }

    var title: String {
        switch self {
        case .camelCase: return "camelCase"
        case .snakeCase: return "snake_case"
        case .kebabCase: return "kebab-case"
        case .titleCase: return "Title Case"
        }
    }
}

struct TextStatistics {
    let characters: Int
    let words: Int
    let lines: Int
    let readingMinutes: Int
}

enum TextProcessingService {
    static func apply(_ action: TextFormatterAction, to text: String) -> String {
        switch action {
        case .trim:
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        case .uppercase:
            return text.uppercased()
        case .lowercase:
            return text.lowercased()
        case .collapseSpaces:
            return collapseWhitespace(in: text)
        case .numberLines:
            return numberLines(in: text)
        case .sortLines:
            return text.split(separator: "\n", omittingEmptySubsequences: false)
                .map(String.init)
                .sorted()
                .joined(separator: "\n")
        case .dedupeLines:
            var seen = Set<String>()
            return text.split(separator: "\n", omittingEmptySubsequences: false)
                .map(String.init)
                .filter { seen.insert($0).inserted }
                .joined(separator: "\n")
        }
    }

    static func convertCase(_ style: CaseNamingStyle, input: String) -> String {
        let tokens = tokenize(input)
        guard !tokens.isEmpty else { return input }
        switch style {
        case .camelCase:
            let first = tokens[0].lowercased()
            let rest = tokens.dropFirst().map { $0.capitalized }
            return ([first] + rest).joined()
        case .snakeCase:
            return tokens.map { $0.lowercased() }.joined(separator: "_")
        case .kebabCase:
            return tokens.map { $0.lowercased() }.joined(separator: "-")
        case .titleCase:
            return tokens.map { $0.capitalized }.joined(separator: " ")
        }
    }

    static func statistics(for text: String) -> TextStatistics {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let characters = text.count
        let lines = text.isEmpty ? 0 : text.split(separator: "\n", omittingEmptySubsequences: false).count
        let words: Int
        if trimmed.isEmpty {
            words = 0
        } else {
            words = trimmed.split { $0.isWhitespace }.count
        }
        let readingMinutes = max(1, Int(ceil(Double(words) / 200.0)))
        return TextStatistics(
            characters: characters,
            words: words,
            lines: lines,
            readingMinutes: words == 0 ? 0 : readingMinutes
        )
    }

    static func previewReplace(
        in text: String,
        find: String,
        replacement: String,
        useRegex: Bool
    ) -> Result<String, TextProcessingError> {
        guard !find.isEmpty else { return .failure(.emptyFind) }
        if useRegex {
            do {
                let regex = try NSRegularExpression(pattern: find)
                let range = NSRange(text.startIndex..., in: text)
                let result = regex.stringByReplacingMatches(
                    in: text,
                    range: range,
                    withTemplate: replacement
                )
                return .success(result)
            } catch {
                return .failure(.invalidRegex)
            }
        }
        return .success(text.replacingOccurrences(of: find, with: replacement))
    }

    private static func collapseWhitespace(in text: String) -> String {
        var result = ""
        var previousWasSpace = false
        for character in text {
            if character.isWhitespace {
                if !previousWasSpace {
                    result.append(" ")
                    previousWasSpace = true
                }
            } else {
                result.append(character)
                previousWasSpace = false
            }
        }
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func numberLines(in text: String) -> String {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        return lines.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n")
    }

    private static func tokenize(_ input: String) -> [String] {
        let cleaned = input
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
        return cleaned
            .split { !$0.isLetter && !$0.isNumber }
            .map(String.init)
            .filter { !$0.isEmpty }
    }
}
