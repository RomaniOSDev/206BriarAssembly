import Foundation
import Combine
import UIKit

final class CaseConverterViewModel: ObservableObject {
    @Published var input: String = ""
    @Published var output: String = ""
    @Published var selectedStyle: CaseNamingStyle = .camelCase

    private let storage: AppStorage

    init(storage: AppStorage) {
        self.storage = storage
    }

    func convert() {
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        output = TextProcessingService.convertCase(selectedStyle, input: input)
        storage.recordTextToolUse()
        HapticManager.completeAction()
    }

    func copyOutput() {
        guard !output.isEmpty else { return }
        UIPasteboard.general.string = output
        HapticManager.lightTap()
    }
}
