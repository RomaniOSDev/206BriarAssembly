import SwiftUI

struct WorkspaceView: View {
    @EnvironmentObject private var storage: AppStorage
    @StateObject private var viewModel: WorkspaceViewModel
    @State private var presetName = ""
    @State private var showSavePresetAlert = false

    init(storage: AppStorage) {
        _viewModel = StateObject(wrappedValue: WorkspaceViewModel(storage: storage))
    }

    private let stepColumns = [GridItem(.adaptive(minimum: 100), spacing: 8)]

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                AppScreenScroll {
                    introCard
                    inputCard
                    pipelineCard
                    presetsCard
                    runSection
                    if !viewModel.outputText.isEmpty || viewModel.hasRunOnce {
                        outputCard
                    }
                }
            }
            .navigationTitle("Workspace")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $viewModel.showSaveSheet) {
                saveSnippetSheet
            }
            .alert("Save Pipeline Preset", isPresented: $showSavePresetAlert) {
                TextField("Preset name", text: $presetName)
                Button("Cancel", role: .cancel) { presetName = "" }
                Button("Save") {
                    viewModel.saveCurrentPipelineAsPreset(name: presetName)
                    presetName = ""
                }
            } message: {
                Text("Save the current step order as a reusable preset.")
            }
        }
    }

    private var introCard: some View {
        AppCard(accent: true) {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Text Pipeline")
                        .font(.title3.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("Paste text, chain transforms, then save the result to your snippet library.")
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Image("WorkspaceHero")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 112, height: 84)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color("AppPrimary").opacity(0.2), lineWidth: 1)
                    )
            }
        }
    }

    private var inputCard: some View {
        AppCard(title: "Source Text") {
            VStack(spacing: 12) {
                Button("Paste from Clipboard") {
                    viewModel.pasteFromClipboard()
                }
                .buttonStyle(SurfaceButtonStyle())
                TextEditor(text: $viewModel.inputText)
                    .frame(minHeight: 120)
                    .scrollContentBackground(.hidden)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .appInsetSurface(cornerRadius: 12)
            }
        }
    }

    private var pipelineCard: some View {
        AppCard(title: "Pipeline Steps", trailing: "\(viewModel.selectedSteps.count) steps") {
            VStack(alignment: .leading, spacing: 14) {
                if viewModel.selectedSteps.isEmpty {
                    Text("Tap steps below to build your pipeline.")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                } else {
                    ForEach(Array(viewModel.selectedSteps.enumerated()), id: \.element.id) { index, step in
                        HStack(spacing: 10) {
                            Text("\(index + 1)")
                                .font(.caption.bold())
                                .foregroundStyle(Color("AppPrimary"))
                                .frame(width: 22, height: 22)
                                .background(Color("AppPrimary").opacity(0.15))
                                .clipShape(Circle())
                            Image(systemName: step.icon)
                                .foregroundStyle(Color("AppPrimary"))
                            Text(step.title)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color("AppTextPrimary"))
                            Spacer()
                            Button {
                                viewModel.removeStep(step)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(Color("AppTextSecondary"))
                            }
                        }
                        .padding(10)
                        .appInsetSurface(cornerRadius: 10)
                    }
                }

                Text("Add Step")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppTextSecondary"))
                LazyVGrid(columns: stepColumns, spacing: 8) {
                    ForEach(PipelineStep.allCases) { step in
                        Button {
                            viewModel.addStep(step)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: step.icon)
                                    .font(.caption)
                                Text(step.title)
                                    .font(.caption2.weight(.semibold))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.6)
                            }
                            .foregroundStyle(
                                viewModel.selectedSteps.contains(step)
                                    ? Color("AppBackground")
                                    : Color("AppTextPrimary")
                            )
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(
                                viewModel.selectedSteps.contains(step)
                                    ? AnyShapeStyle(AppGradients.primary)
                                    : AnyShapeStyle(Color("AppBackground").opacity(0.5))
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .disabled(viewModel.selectedSteps.contains(step))
                    }
                }

                Button("Save as Preset") {
                    showSavePresetAlert = true
                }
                .buttonStyle(SurfaceButtonStyle())
                .disabled(viewModel.selectedSteps.isEmpty)
                .opacity(viewModel.selectedSteps.isEmpty ? 0.5 : 1)
            }
        }
    }

    private var presetsCard: some View {
        AppCard(title: "Saved Presets") {
            VStack(spacing: 8) {
                ForEach(viewModel.savedPipelines) { pipeline in
                    Button {
                        viewModel.loadPipeline(pipeline)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(pipeline.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color("AppTextPrimary"))
                                Text(pipeline.steps.map(\.title).joined(separator: " → "))
                                    .font(.caption2)
                                    .foregroundStyle(Color("AppTextSecondary"))
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.7)
                            }
                            Spacer()
                            Image(systemName: "arrow.down.circle")
                                .foregroundStyle(Color("AppPrimary"))
                        }
                        .padding(12)
                        .appInsetSurface(cornerRadius: 10)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var runSection: some View {
        VStack(spacing: 8) {
            if let error = viewModel.saveError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            Button("Run Pipeline") {
                viewModel.runPipeline()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
    }

    private var outputCard: some View {
        AppCard(title: "Output", accent: true) {
            VStack(spacing: 12) {
                Text(viewModel.outputText)
                    .font(.body)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                HStack(spacing: 10) {
                    Button("Copy") { viewModel.copyOutput() }
                        .buttonStyle(SurfaceButtonStyle())
                    Button("Use as Input") { viewModel.applyOutputToInput() }
                        .buttonStyle(SurfaceButtonStyle())
                }
                Button("Save to Library") {
                    viewModel.showSaveSheet = true
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }

    private var saveSnippetSheet: some View {
        NavigationStack {
            AppBackgroundView {
                AppScreenScroll {
                    AppCard(title: "Save Snippet") {
                        VStack(spacing: 12) {
                            AppStyledTextField(placeholder: "Tag", text: $viewModel.saveTag)
                            Text(viewModel.outputText)
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(6)
                        }
                    }
                    Button("Save") {
                        viewModel.saveOutputToLibrary()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .navigationTitle("Save Snippet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.showSaveSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
