import SwiftUI

struct LibraryView: View {
    @ObservedObject var viewModel: LibraryViewModel
    var isSidebar: Bool = false
    var onRunPipeline: ((ClipboardEntry) -> Void)?
    var onSendToWorkspace: ((ClipboardEntry) -> Void)?

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                VStack(spacing: 0) {
                    filtersBar
                    contentList
                    if !isSidebar {
                        saveBar
                    }
                }
            }
            .navigationTitle(isSidebar ? "Snippets" : "Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(item: $viewModel.editingEntry) { _ in
                editSheet
            }
        }
    }

    @ViewBuilder
    private var contentList: some View {
        if viewModel.isEmptyStorage {
            AppEmptyStateView(
                icon: "terminal.fill",
                title: "No Log Snippets",
                message: "Paste a log in Pipeline or save text from your clipboard.",
                imageName: isSidebar ? nil : "LibraryEmpty"
            )
            .frame(maxHeight: .infinity)
        } else if viewModel.entries.isEmpty {
            AppEmptyStateView(
                icon: "magnifyingglass",
                title: "No Results",
                message: "Try another search, tag, or date filter."
            )
            .frame(maxHeight: .infinity)
        } else {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.entries) { entry in
                        snippetRow(entry)
                    }
                }
                .padding(.horizontal, isSidebar ? 12 : 16)
                .padding(.bottom, 12)
            }
        }
    }

    private func snippetRow(_ entry: ClipboardEntry) -> some View {
        VStack(spacing: 8) {
            AppSnippetCell(tag: entry.tag, date: entry.savedAt, preview: entry.text)
                .scaleEffect(viewModel.animateNewEntryID == entry.id ? 1.02 : 1)
                .animation(.easeOut(duration: 0.2), value: viewModel.animateNewEntryID)
                .onTapGesture {
                    onSendToWorkspace?(entry)
                }
                .contextMenu {
                    if let onRunPipeline {
                        Button("Run Pipeline") { onRunPipeline(entry) }
                    }
                    if let onSendToWorkspace {
                        Button("Open in Pipeline") { onSendToWorkspace(entry) }
                    }
                    Button("Copy") { viewModel.copyToClipboard(entry.text) }
                    Button("Edit") { viewModel.beginEdit(entry) }
                    Button("Delete", role: .destructive) { viewModel.delete(id: entry.id) }
                }

            if onRunPipeline != nil || onSendToWorkspace != nil {
                HStack(spacing: 10) {
                    if let onRunPipeline {
                        Button("Run Pipeline") { onRunPipeline(entry) }
                            .buttonStyle(PrimaryButtonStyle())
                    }
                    if let onSendToWorkspace {
                        Button("Open in Pipeline") { onSendToWorkspace(entry) }
                            .buttonStyle(SurfaceButtonStyle())
                    }
                }
            }
        }
    }

    private var filtersBar: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color("AppPrimary"))
                AppStyledTextField(placeholder: "Search log snippets", text: $viewModel.searchText)
            }
            .padding(.horizontal, isSidebar ? 12 : 16)
            .padding(.top, 12)

            if !isSidebar {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.allTags, id: \.self) { tag in
                            AppChip(title: tag, isSelected: viewModel.selectedTag == tag) {
                                viewModel.selectedTag = tag
                                HapticManager.lightTap()
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }

                Picker("Date", selection: $viewModel.dateFilter) {
                    ForEach(ClipboardDateFilter.allCases) { filter in
                        Text(filter.title).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.allTags, id: \.self) { tag in
                            AppChip(title: tag, isSelected: viewModel.selectedTag == tag) {
                                viewModel.selectedTag = tag
                                HapticManager.lightTap()
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                }
                .padding(.bottom, 8)
            }
        }
    }

    private var saveBar: some View {
        VStack(spacing: 8) {
            if let error = viewModel.saveError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            AppCard(title: "Quick Save") {
                VStack(spacing: 10) {
                    AppStyledTextField(placeholder: "Tag", text: $viewModel.newSnippetTag)
                    Button("Save Clipboard") {
                        viewModel.saveFromClipboard()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }

    private var editSheet: some View {
        NavigationStack {
            AppBackgroundView {
                AppScreenScroll {
                    AppCard(title: "Edit Snippet") {
                        VStack(spacing: 12) {
                            AppStyledTextField(placeholder: "Tag", text: $viewModel.editTag)
                            AppStyledTextField(
                                placeholder: "Snippet text",
                                text: $viewModel.editText,
                                axis: .vertical,
                                lineLimit: 5...12
                            )
                        }
                    }
                }
            }
            .navigationTitle("Edit Snippet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { viewModel.editingEntry = nil }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { viewModel.saveEdit() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
