import SwiftUI

struct CaseConverterView: View {
    @EnvironmentObject private var storage: AppStorage
    @StateObject private var viewModel: CaseConverterViewModel

    init(storage: AppStorage) {
        _viewModel = StateObject(wrappedValue: CaseConverterViewModel(storage: storage))
    }

    var body: some View {
        AppScreenScroll {
            TextToolEditorCard(title: "Input", text: $viewModel.input, minHeight: 100)

            AppCard(title: "Naming Style") {
                Picker("Style", selection: $viewModel.selectedStyle) {
                    ForEach(CaseNamingStyle.allCases) { style in
                        Text(style.title).tag(style)
                    }
                }
                .pickerStyle(.segmented)
            }

            Button("Convert") {
                viewModel.convert()
            }
            .buttonStyle(PrimaryButtonStyle())

            if !viewModel.output.isEmpty {
                AppCard(title: "Output", accent: true) {
                    Text(viewModel.output)
                        .font(.body.monospaced())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                Button("Copy Output") {
                    viewModel.copyOutput()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }
}
