import Foundation
import Combine
import UIKit

final class WorkspaceViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var outputText: String = ""
    @Published var selectedSteps: [PipelineStep] = []
    @Published var regexPattern: String = ""
    @Published var regexReplacement: String = ""
    @Published var regexUseRegex: Bool = true
    @Published var showSaveSheet = false
    @Published var saveTag: String = "Logs"
    @Published var saveError: String?
    @Published var hasRunOnce = false
    @Published var loadedSnippetTitle: String?

    private let storage: AppStorage
    private var cancellables = Set<AnyCancellable>()

    var savedPipelines: [SavedPipeline] {
        storage.savedPipelines
    }

    var livePreviews: [PipelineLivePreview] {
        guard !inputText.isEmpty, !selectedSteps.isEmpty else { return [] }
        return TextPipelineService.livePreviews(
            steps: selectedSteps,
            on: inputText,
            regexConfig: currentRegexConfig
        )
    }

    var showsRegexConfig: Bool {
        selectedSteps.contains(.regexReplace)
    }

    init(storage: AppStorage) {
        self.storage = storage
        selectedSteps = storage.activePipelineSteps
        regexPattern = storage.regexStepConfig.pattern
        regexReplacement = storage.regexStepConfig.replacement
        regexUseRegex = storage.regexStepConfig.useRegex

        storage.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        Publishers.CombineLatest3($regexPattern, $regexReplacement, $regexUseRegex)
            .dropFirst()
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .sink { [weak self] pattern, replacement, useRegex in
                self?.persistRegexConfig(pattern: pattern, replacement: replacement, useRegex: useRegex)
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
        loadedSnippetTitle = nil
        saveError = nil
        HapticManager.lightTap()
    }

    func loadFromSnippet(_ entry: ClipboardEntry) {
        inputText = entry.text
        saveTag = entry.tag
        loadedSnippetTitle = entry.tag
        hasRunOnce = false
        outputText = ""
        saveError = nil
        HapticManager.lightTap()
    }

    func runPipelineOnSnippet(_ entry: ClipboardEntry) {
        loadFromSnippet(entry)
        runPipeline()
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
        if let config = pipeline.regexConfig {
            regexPattern = config.pattern
            regexReplacement = config.replacement
            regexUseRegex = config.useRegex
            persistRegexConfig(pattern: config.pattern, replacement: config.replacement, useRegex: config.useRegex)
        }
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
        if selectedSteps.contains(.regexReplace), regexPattern.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            saveError = "Enter a regex pattern for the Regex Replace step."
            HapticManager.warning()
            return
        }
        saveError = nil
        outputText = TextPipelineService.run(
            steps: selectedSteps,
            on: inputText,
            regexConfig: currentRegexConfig
        )
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
        loadedSnippetTitle = nil
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
        let entry = ClipboardEntry(text: trimmed, tag: tag.isEmpty ? "Logs" : tag)
        storage.addClipboardEntry(entry)
        showSaveSheet = false
        HapticManager.completeAction()
    }

    func saveCurrentPipelineAsPreset(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !selectedSteps.isEmpty else { return }
        let config = selectedSteps.contains(.regexReplace) ? currentRegexConfig : nil
        storage.saveCustomPipeline(SavedPipeline(name: trimmed, steps: selectedSteps, regexConfig: config))
        HapticManager.completeAction()
    }

    private var currentRegexConfig: RegexStepConfig {
        RegexStepConfig(
            pattern: regexPattern,
            replacement: regexReplacement,
            useRegex: regexUseRegex
        )
    }

    private func persistSteps() {
        storage.activePipelineSteps = selectedSteps
    }

    private func persistRegexConfig(pattern: String, replacement: String, useRegex: Bool) {
        storage.regexStepConfig = RegexStepConfig(
            pattern: pattern,
            replacement: replacement,
            useRegex: useRegex
        )
    }
}
