import SwiftUI

struct TextFormatterView: View {
    @EnvironmentObject private var storage: AppStorage
    @StateObject private var viewModel: TextFormatterViewModel

    init(storage: AppStorage) {
        _viewModel = StateObject(wrappedValue: TextFormatterViewModel(storage: storage))
    }

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        AppScreenScroll {
            TextToolEditorCard(title: "Input", text: $viewModel.input, minHeight: 130)

            AppCard(title: "Actions") {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(TextFormatterAction.allCases) { action in
                        AppFormatterActionCell(title: action.title, icon: action.icon) {
                            viewModel.apply(action)
                        }
                    }
                }
            }

            TextToolEditorCard(title: "Output", text: $viewModel.output, minHeight: 130)

            if !viewModel.output.isEmpty {
                Button("Copy Output") {
                    viewModel.copyOutput()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }
}
