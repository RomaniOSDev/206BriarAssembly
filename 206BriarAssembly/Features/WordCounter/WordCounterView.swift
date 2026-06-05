import SwiftUI

struct WordCounterView: View {
    @StateObject private var viewModel = WordCounterViewModel()

    var body: some View {
        AppScreenScroll {
            TextToolEditorCard(title: "Text", text: $viewModel.input, minHeight: 150)

            AppCard(title: "Statistics") {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    AppMetricTile(value: "\(viewModel.stats.characters)", label: "Characters", icon: "textformat.123")
                    AppMetricTile(value: "\(viewModel.stats.words)", label: "Words", icon: "doc.text")
                    AppMetricTile(value: "\(viewModel.stats.lines)", label: "Lines", icon: "list.bullet")
                    AppMetricTile(
                        value: viewModel.stats.words == 0 ? "—" : "\(viewModel.stats.readingMinutes) min",
                        label: "Reading",
                        icon: "book"
                    )
                }
            }
        }
    }
}
