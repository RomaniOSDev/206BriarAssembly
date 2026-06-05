import SwiftUI

struct ColorInspectorView: View {
    @EnvironmentObject private var storage: AppStorage
    @StateObject private var viewModel: ColorInspectorViewModel
    @State private var showSuccessCheck = false

    init(storage: AppStorage) {
        _viewModel = StateObject(wrappedValue: ColorInspectorViewModel(storage: storage))
    }

    var body: some View {
        ZStack {
            AppScreenScroll {
                if viewModel.showEmptyState {
                    AppEmptyStateView(
                        icon: "paintpalette.fill",
                        title: "Inspect Colors",
                        message: "Enter a color code above to begin!"
                    )
                }

                AppCard(title: "Color Input") {
                    AppStyledTextField(placeholder: "Enter Color Code", text: $viewModel.input)
                        .shake(trigger: viewModel.shakeTrigger)
                    Button("Inspect") {
                        viewModel.inspect()
                        if !viewModel.results.isEmpty {
                            SuccessCheckmarkOverlay.show(binding: $showSuccessCheck)
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(!viewModel.canInspect)
                    .opacity(viewModel.canInspect ? 1 : 0.5)
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                if let swatch = viewModel.parsedColor {
                    AppCard(title: "Preview") {
                        ColorSwatchPath(color: swatch)
                            .frame(height: 88)
                            .frame(maxWidth: .infinity)
                    }
                }

                recentColorsSection

                if !viewModel.results.isEmpty {
                    AppCard(title: "Formats") {
                        VStack(spacing: 10) {
                            ForEach(viewModel.results) { result in
                                colorResultCell(result)
                            }
                        }
                    }
                }
            }
            SuccessCheckmarkOverlay(isVisible: $showSuccessCheck)
        }
    }

    private var recentColorsSection: some View {
        Group {
            if !storage.recentColors.isEmpty {
                AppCard(title: "Recent Palette") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 76), spacing: 10)], spacing: 10) {
                        ForEach(storage.recentColors, id: \.self) { hex in
                            Button {
                                viewModel.copyHex(hex)
                            } label: {
                                VStack(spacing: 6) {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(viewModel.color(fromHex: hex))
                                        .frame(height: 48)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .stroke(Color("AppTextSecondary").opacity(0.25), lineWidth: 1)
                                        )
                                    Text(hex)
                                        .font(.caption2.monospaced())
                                        .foregroundStyle(Color("AppTextSecondary"))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.6)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private func colorResultCell(_ result: ColorFormatResult) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(result.name)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppTextSecondary"))
                Text(result.value)
                    .font(.body.monospaced())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
            Spacer()
            Image(systemName: "doc.on.doc")
                .foregroundStyle(Color("AppPrimary"))
        }
        .padding(12)
        .appInsetSurface(cornerRadius: 12)
        .scaleEffect(viewModel.resultPulse ? 1.02 : 1)
        .animation(.easeOut(duration: 0.2), value: viewModel.resultPulse)
        .onLongPressGesture {
            viewModel.copyValue(result.value)
        }
    }
}

private struct ColorSwatchPath: View {
    let color: Color

    var body: some View {
        GeometryReader { geo in
            Path { path in
                let w = geo.size.width
                let h = geo.size.height
                path.move(to: CGPoint(x: 0, y: h))
                path.addLine(to: CGPoint(x: w * 0.3, y: 0))
                path.addLine(to: CGPoint(x: w, y: 0))
                path.addLine(to: CGPoint(x: w * 0.7, y: h))
                path.closeSubpath()
            }
            .fill(color)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color("AppTextSecondary").opacity(0.3), lineWidth: 1)
            )
        }
    }
}
