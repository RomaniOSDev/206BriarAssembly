import SwiftUI

enum ToolDestination: String, CaseIterable, Identifiable, Hashable {
    case clipboard
    case colors
    case textFormatter
    case caseConverter
    case wordCounter
    case findReplace

    var id: String { rawValue }

    var title: String {
        switch self {
        case .clipboard: return "Clipboard Manager"
        case .colors: return "Color Inspector"
        case .textFormatter: return "Text Formatter"
        case .caseConverter: return "Case Converter"
        case .wordCounter: return "Word Counter"
        case .findReplace: return "Find & Replace"
        }
    }

    var subtitle: String {
        switch self {
        case .clipboard: return "Save, tag, and search snippets"
        case .colors: return "Convert hex, RGB, and HSL"
        case .textFormatter: return "Trim, sort, and clean text"
        case .caseConverter: return "camelCase, snake_case, and more"
        case .wordCounter: return "Words, lines, reading time"
        case .findReplace: return "Find and replace with regex"
        }
    }

    var icon: String {
        switch self {
        case .clipboard: return "doc.on.clipboard.fill"
        case .colors: return "paintpalette.fill"
        case .textFormatter: return "text.alignleft"
        case .caseConverter: return "textformat.abc"
        case .wordCounter: return "textformat.123"
        case .findReplace: return "arrow.left.arrow.right.circle.fill"
        }
    }
}

struct ToolsHubView: View {
    @EnvironmentObject private var storage: AppStorage

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                AppScreenScroll {
                    AppCard(title: "Text Utilities") {
                        VStack(spacing: 10) {
                            ForEach(ToolDestination.allCases) { tool in
                                NavigationLink(value: tool) {
                                    AppNavigationCell(
                                        icon: tool.icon,
                                        title: tool.title,
                                        subtitle: tool.subtitle
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Tools")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationDestination(for: ToolDestination.self) { tool in
                AppBackgroundView {
                    toolView(for: tool)
                }
                .navigationTitle(tool.title)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    @ViewBuilder
    private func toolView(for tool: ToolDestination) -> some View {
        switch tool {
        case .clipboard:
            ClipboardManagerView(storage: storage)
        case .colors:
            ColorInspectorView(storage: storage)
        case .textFormatter:
            TextFormatterView(storage: storage)
        case .caseConverter:
            CaseConverterView(storage: storage)
        case .wordCounter:
            WordCounterView()
        case .findReplace:
            FindReplaceView(storage: storage)
        }
    }
}
