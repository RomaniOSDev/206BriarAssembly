import SwiftUI

struct ClipboardManagerView: View {
    @EnvironmentObject private var storage: AppStorage
    @StateObject private var viewModel: ClipboardManagerViewModel

    init(storage: AppStorage) {
        _viewModel = StateObject(wrappedValue: ClipboardManagerViewModel(storage: storage))
    }

    var body: some View {
        VStack(spacing: 0) {
            filtersBar

            Group {
                if viewModel.isEmptyStorage {
                    AppEmptyStateView(
                        icon: "doc.on.clipboard.fill",
                        title: "No Snippets Yet",
                        message: "Tap Save Clipboard to capture your first snippet."
                    )
                    .padding(16)
                } else if viewModel.entries.isEmpty {
                    AppEmptyStateView(
                        icon: "magnifyingglass",
                        title: "No Results",
                        message: "Try another search, tag, or date filter."
                    )
                    .padding(16)
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.entries) { entry in
                                AppSnippetCell(tag: entry.tag, date: entry.savedAt, preview: entry.text)
                                    .scaleEffect(viewModel.animateNewEntryID == entry.id ? 1.02 : 1)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.animateNewEntryID)
                                    .onTapGesture {
                                        viewModel.beginEdit(entry)
                                        HapticManager.lightTap()
                                    }
                                    .contextMenu {
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
            .frame(maxHeight: .infinity)

            if let error = viewModel.saveError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 16)
            }

            AppCard(title: "Save New Snippet") {
                VStack(spacing: 12) {
                    AppStyledTextField(placeholder: "Tag (e.g. Work)", text: $viewModel.newSnippetTag)
                    Button("Save Clipboard") {
                        viewModel.saveFromClipboard()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .padding(16)
        }
        .sheet(item: $viewModel.editingEntry) { _ in
            editSheet
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
                    Button("Cancel") {
                        viewModel.editingEntry = nil
                        HapticManager.lightTap()
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveEdit()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
