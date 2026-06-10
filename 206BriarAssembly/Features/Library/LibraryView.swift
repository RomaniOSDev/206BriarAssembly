import SwiftUI

struct LibraryView: View {
    @EnvironmentObject private var storage: AppStorage
    @StateObject private var viewModel: LibraryViewModel

    init(storage: AppStorage) {
        _viewModel = StateObject(wrappedValue: LibraryViewModel(storage: storage))
    }

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                VStack(spacing: 0) {
                    filtersBar
                    contentList
                    saveBar
                }
            }
            .navigationTitle("Library")
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
                icon: "books.vertical.fill",
                title: "No Snippets Yet",
                message: "Run a pipeline in Workspace or save text from your clipboard.",
                imageName: "LibraryEmpty"
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
                        AppSnippetCell(tag: entry.tag, date: entry.savedAt, preview: entry.text)
                            .scaleEffect(viewModel.animateNewEntryID == entry.id ? 1.02 : 1)
                            .animation(.easeOut(duration: 0.2), value: viewModel.animateNewEntryID)
                            .onTapGesture {
                                viewModel.copyToClipboard(entry.text)
                            }
                            .contextMenu {
                                Button("Copy") { viewModel.copyToClipboard(entry.text) }
                                Button("Edit") { viewModel.beginEdit(entry) }
                                Button("Delete", role: .destructive) { viewModel.delete(id: entry.id) }
                            }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
        }
    }

    private var filtersBar: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color("AppPrimary"))
                AppStyledTextField(placeholder: "Search snippets", text: $viewModel.searchText)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

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
