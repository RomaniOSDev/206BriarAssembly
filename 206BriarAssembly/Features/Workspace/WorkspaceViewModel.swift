import Foundation
import Combine
import UIKit

final class WorkspaceViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var outputText: String = ""
    @Published var selectedSteps: [PipelineStep] = []
    @Published var showSaveSheet = false
    @Published var saveTag: String = "General"
    @Published var saveError: String?
    @Published var hasRunOnce = false

    private let storage: AppStorage
    private var cancellables = Set<AnyCancellable>()

    var savedPipelines: [SavedPipeline] {
        storage.savedPipelines
    }

    init(storage: AppStorage) {
        self.storage = storage
        selectedSteps = storage.activePipelineSteps
        storage.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    func pasteFromClipboard() {
        guard let text = UIPasteboard.general.string, !text.isEmpty else {
            saveError = "Clipboard is empty."
            HapticManager.warning()
            return
        }
        inputText = text
        saveError = nil
        HapticManager.lightTap()
    }

    func addStep(_ step: PipelineStep) {
        guard !selectedSteps.contains(step) else { return }
        selectedSteps.append(step)
        persistSteps()
        HapticManager.lightTap()
    }

    func removeStep(_ step: PipelineStep) {
        selectedSteps.removeAll { $0 == step }
        persistSteps()
        HapticManager.lightTap()
    }

    func loadPipeline(_ pipeline: SavedPipeline) {
        selectedSteps = pipeline.steps
        persistSteps()
        HapticManager.lightTap()
    }

    func runPipeline() {
        guard !inputText.isEmpty else {
            saveError = "Enter or paste text first."
            HapticManager.warning()
            return
        }
        guard !selectedSteps.isEmpty else {
            saveError = "Add at least one pipeline step."
            HapticManager.warning()
            return
        }
        saveError = nil
        outputText = TextPipelineService.run(steps: selectedSteps, on: inputText)
        hasRunOnce = true
        HapticManager.completeAction()
    }

    func copyOutput() {
        guard !outputText.isEmpty else { return }
        UIPasteboard.general.string = outputText
        HapticManager.lightTap()
    }

    func applyOutputToInput() {
        guard !outputText.isEmpty else { return }
        inputText = outputText
        HapticManager.lightTap()
    }

    func saveOutputToLibrary() {
        let trimmed = outputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            saveError = "Run the pipeline before saving."
            HapticManager.warning()
            return
        }
        let tag = saveTag.trimmingCharacters(in: .whitespacesAndNewlines)
        let entry = ClipboardEntry(text: trimmed, tag: tag.isEmpty ? "General" : tag)
        storage.addClipboardEntry(entry)
        showSaveSheet = false
        HapticManager.completeAction()
    }

    func saveCurrentPipelineAsPreset(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !selectedSteps.isEmpty else { return }
        storage.saveCustomPipeline(SavedPipeline(name: trimmed, steps: selectedSteps))
        HapticManager.completeAction()
    }

    private func persistSteps() {
        storage.activePipelineSteps = selectedSteps
    }
}
