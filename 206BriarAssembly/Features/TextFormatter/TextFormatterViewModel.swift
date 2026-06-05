import Foundation
import Combine
import UIKit

final class TextFormatterViewModel: ObservableObject {
    @Published var input: String = ""
    @Published var output: String = ""

    private let storage: AppStorage

    init(storage: AppStorage) {
        self.storage = storage
    }

    func apply(_ action: TextFormatterAction) {
        guard !input.isEmpty else { return }
        output = TextProcessingService.apply(action, to: input)
        storage.recordTextToolUse()
        HapticManager.completeAction()
    }

    func copyOutput() {
        guard !output.isEmpty else { return }
        UIPasteboard.general.string = output
        HapticManager.lightTap()
    }
}
