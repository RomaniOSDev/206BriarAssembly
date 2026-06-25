import Foundation
import Combine
import UIKit
import AudioToolbox

enum ClipboardDateFilter: String, CaseIterable, Identifiable {
    case all
    case today
    case week
    case month

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All Dates"
        case .today: return "Today"
        case .week: return "This Week"
        case .month: return "This Month"
        }
    }
}

final class LibraryViewModel: ObservableObject {
    @Published var editingEntry: ClipboardEntry?
    @Published var editText: String = ""
    @Published var editTag: String = "Logs"
    @Published var animateNewEntryID: UUID?
    @Published var saveError: String?
    @Published var searchText: String = ""
    @Published var selectedTag: String = "All"
    @Published var dateFilter: ClipboardDateFilter = .all
    @Published var newSnippetTag: String = "Logs"

    private let storage: AppStorage
    private var cancellables = Set<AnyCancellable>()

    var allTags: [String] {
        storage.clipboardTags
    }

    var filteredEntries: [ClipboardEntry] {
        storage.clipboardHistory.filter { entry in
            matchesSearch(entry) && matchesTag(entry) && matchesDate(entry)
        }
    }

    var entries: [ClipboardEntry] {
        filteredEntries
    }

    var isEmptyStorage: Bool {
        storage.clipboardHistory.isEmpty
    }

    init(storage: AppStorage) {
        self.storage = storage
        storage.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    func saveFromClipboard() {
        guard let text = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            saveError = "Clipboard is empty."
            HapticManager.warning()
            return
        }
        saveError = nil
        let tag = newSnippetTag.trimmingCharacters(in: .whitespacesAndNewlines)
        let entry = ClipboardEntry(text: text, tag: tag.isEmpty ? "General" : tag)
        storage.addClipboardEntry(entry)
        animateNewEntryID = entry.id
        HapticManager.lightTap()
        AudioServicesPlaySystemSound(1104)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.animateNewEntryID = nil
        }
    }

    func beginEdit(_ entry: ClipboardEntry) {
        editingEntry = entry
        editText = entry.text
        editTag = entry.tag
    }

    func saveEdit() {
        guard var entry = editingEntry else { return }
        let trimmed = editText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            saveError = "Snippet cannot be empty."
            HapticManager.warning()
            return
        }
        entry.text = trimmed
        entry.tag = editTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "General" : editTag
        storage.updateClipboardEntry(entry)
        editingEntry = nil
        HapticManager.completeAction()
    }

    func delete(id: UUID) {
        storage.deleteClipboardEntry(id: id)
        HapticManager.lightTap()
    }

    func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        HapticManager.lightTap()
    }

    private func matchesSearch(_ entry: ClipboardEntry) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return true }
        return entry.text.localizedCaseInsensitiveContains(query)
    }

    private func matchesTag(_ entry: ClipboardEntry) -> Bool {
        selectedTag == "All" || entry.tag == selectedTag
    }

    private func matchesDate(_ entry: ClipboardEntry) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        switch dateFilter {
        case .all:
            return true
        case .today:
            return calendar.isDateInToday(entry.savedAt)
        case .week:
            guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) else { return true }
            return entry.savedAt >= weekAgo
        case .month:
            guard let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) else { return true }
            return entry.savedAt >= monthAgo
        }
    }
}
