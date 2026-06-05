import Foundation
import Combine
import UIKit

final class FindReplaceViewModel: ObservableObject {
    @Published var sourceText: String = ""
    @Published var findText: String = ""
    @Published var replaceText: String = ""
    @Published var useRegex = false
    @Published var previewText: String?
    @Published var errorMessage: String?
    @Published var shakeTrigger = 0

    private let storage: AppStorage

    init(storage: AppStorage) {
        self.storage = storage
    }

    func generatePreview() {
        errorMessage = nil
        switch TextProcessingService.previewReplace(
            in: sourceText,
            find: findText,
            replacement: replaceText,
            useRegex: useRegex
        ) {
        case .success(let result):
            previewText = result
            HapticManager.lightTap()
        case .failure(let error):
            errorMessage = error.localizedDescription
            previewText = nil
            shakeTrigger += 1
            HapticManager.warning()
        }
    }

    func applyReplacement() {
        if previewText == nil {
            generatePreview()
        }
        guard let preview = previewText else { return }
        sourceText = preview
        previewText = nil
        storage.recordTextToolUse()
        HapticManager.completeAction()
    }

    func pasteFromClipboard() {
        if let text = UIPasteboard.general.string {
            sourceText = text
            HapticManager.lightTap()
        }
    }

    func copyResult() {
        guard !sourceText.isEmpty else { return }
        UIPasteboard.general.string = sourceText
        HapticManager.lightTap()
    }
}
