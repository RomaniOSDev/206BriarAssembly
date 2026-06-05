import SwiftUI

struct FindReplaceView: View {
    @EnvironmentObject private var storage: AppStorage
    @StateObject private var viewModel: FindReplaceViewModel

    init(storage: AppStorage) {
        _viewModel = StateObject(wrappedValue: FindReplaceViewModel(storage: storage))
    }

    var body: some View {
        AppScreenScroll {
            Button("Paste from Clipboard") {
                viewModel.pasteFromClipboard()
            }
            .buttonStyle(SurfaceButtonStyle())

            TextToolEditorCard(title: "Source Text", text: $viewModel.sourceText, minHeight: 110)

            AppCard(title: "Find & Replace") {
                VStack(spacing: 12) {
                    AppStyledTextField(placeholder: "Find", text: $viewModel.findText)
                        .shake(trigger: viewModel.shakeTrigger)
                    AppStyledTextField(placeholder: "Replace with", text: $viewModel.replaceText)
                    Toggle("Use Regular Expression", isOn: $viewModel.useRegex)
                        .tint(Color("AppPrimary"))
                        .foregroundStyle(Color("AppTextPrimary"))
                }
            }

            HStack(spacing: 12) {
                Button("Preview") {
                    viewModel.generatePreview()
                }
                .buttonStyle(SurfaceButtonStyle())
                if viewModel.previewText != nil {
                    Button("Apply") {
                        viewModel.applyReplacement()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            if let preview = viewModel.previewText {
                AppCard(title: "Preview", accent: true) {
                    Text(preview)
                        .font(.body)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Button("Copy Text") {
                viewModel.copyResult()
            }
            .buttonStyle(SurfaceButtonStyle())
        }
    }
}
