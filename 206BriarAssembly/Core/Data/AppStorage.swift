import Foundation
import Combine

final class AppStorage: ObservableObject {
    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let clipboardHistory = "clipboardHistory"
        static let lastSavedDate = "lastSavedDate"
        static let savedPipelines = "savedPipelines"
        static let activePipelineSteps = "activePipelineSteps"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var clipboardHistory: [ClipboardEntry] {
        didSet { saveClipboardHistory() }
    }

    @Published var lastSavedDate: Date? {
        didSet {
            if let date = lastSavedDate {
                defaults.set(date, forKey: Keys.lastSavedDate)
            } else {
                defaults.removeObject(forKey: Keys.lastSavedDate)
            }
        }
    }

    @Published var savedPipelines: [SavedPipeline] {
        didSet { saveSavedPipelines() }
    }

    @Published var activePipelineSteps: [PipelineStep] {
        didSet { saveActivePipelineSteps() }
    }

    var snippetCount: Int { clipboardHistory.count }

    var clipboardTags: [String] {
        let tags = Set(clipboardHistory.map(\.tag))
        return ["All"] + tags.sorted()
    }

    private var cancellables = Set<AnyCancellable>()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        clipboardHistory = Self.loadJSON([ClipboardEntry].self, key: Keys.clipboardHistory, defaults: defaults) ?? []
        lastSavedDate = defaults.object(forKey: Keys.lastSavedDate) as? Date
        savedPipelines = Self.loadJSON([SavedPipeline].self, key: Keys.savedPipelines, defaults: defaults) ?? []
        activePipelineSteps = Self.loadPipelineSteps(from: defaults)

        if savedPipelines.isEmpty {
            savedPipelines = PipelinePreset.all
        }

        NotificationCenter.default.publisher(for: .dataReset)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reloadFromDefaults()
            }
            .store(in: &cancellables)
    }

    func completeOnboarding() {
        hasSeenOnboarding = true
    }

    func addClipboardEntry(_ entry: ClipboardEntry) {
        clipboardHistory.insert(entry, at: 0)
        lastSavedDate = entry.savedAt
    }

    func updateClipboardEntry(_ entry: ClipboardEntry) {
        if let index = clipboardHistory.firstIndex(where: { $0.id == entry.id }) {
            clipboardHistory[index] = entry
        }
    }

    func deleteClipboardEntry(id: UUID) {
        clipboardHistory.removeAll { $0.id == id }
    }

    func saveCustomPipeline(_ pipeline: SavedPipeline) {
        if let index = savedPipelines.firstIndex(where: { $0.id == pipeline.id }) {
            savedPipelines[index] = pipeline
        } else {
            savedPipelines.insert(pipeline, at: 0)
        }
        if savedPipelines.count > 20 {
            savedPipelines = Array(savedPipelines.prefix(20))
        }
    }

    func deletePipeline(id: UUID) {
        savedPipelines.removeAll { $0.id == id }
    }

    func exportBackupData() throws -> Data {
        try BackupManager.encode(BackupManager.makeBackup(from: self))
    }

    func importBackupData(_ data: Data) throws {
        let backup = try BackupManager.decode(data)
        BackupManager.apply(backup, to: self)
    }

    func resetAllData() {
        let keys = [
            Keys.hasSeenOnboarding,
            Keys.clipboardHistory,
            Keys.lastSavedDate,
            Keys.savedPipelines,
            Keys.activePipelineSteps
        ]
        keys.forEach { defaults.removeObject(forKey: $0) }
        defaults.synchronize()
        reloadFromDefaults()
        savedPipelines = PipelinePreset.all
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    private func reloadFromDefaults() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        clipboardHistory = Self.loadJSON([ClipboardEntry].self, key: Keys.clipboardHistory, defaults: defaults) ?? []
        lastSavedDate = defaults.object(forKey: Keys.lastSavedDate) as? Date
        savedPipelines = Self.loadJSON([SavedPipeline].self, key: Keys.savedPipelines, defaults: defaults) ?? PipelinePreset.all
        activePipelineSteps = Self.loadPipelineSteps(from: defaults)
    }

    private func saveClipboardHistory() {
        if let data = try? encoder.encode(clipboardHistory) {
            defaults.set(data, forKey: Keys.clipboardHistory)
        }
    }

    private func saveSavedPipelines() {
        if let data = try? encoder.encode(savedPipelines) {
            defaults.set(data, forKey: Keys.savedPipelines)
        }
    }

    private func saveActivePipelineSteps() {
        let raw = activePipelineSteps.map(\.rawValue)
        defaults.set(raw, forKey: Keys.activePipelineSteps)
    }

    private static func loadPipelineSteps(from defaults: UserDefaults) -> [PipelineStep] {
        guard let raw = defaults.stringArray(forKey: Keys.activePipelineSteps) else {
            return PipelinePreset.cleanNotes.steps
        }
        return raw.compactMap(PipelineStep.init(rawValue:))
    }

    private static func loadJSON<T: Decodable>(
        _ type: T.Type,
        key: String,
        defaults: UserDefaults
    ) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
