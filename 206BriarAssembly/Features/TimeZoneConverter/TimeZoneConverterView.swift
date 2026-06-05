import SwiftUI
import Combine
import UIKit

struct TimeZoneConverterView: View {
    @EnvironmentObject private var storage: AppStorage
    @StateObject private var viewModel: TimeZoneConverterViewModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var showSuccessCheck = false
    @State private var clockDate = Date()

    init(storage: AppStorage) {
        _viewModel = StateObject(wrappedValue: TimeZoneConverterViewModel(storage: storage))
    }

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                ZStack {
                    AppScreenScroll {
                        localTimeHero

                        if viewModel.showEmptyState {
                            AppCard {
                                VStack(spacing: 12) {
                                    WorldMapIllustration()
                                        .frame(height: 140)
                                    Text("Convert times across the globe")
                                        .font(.subheadline)
                                        .foregroundStyle(Color("AppTextSecondary"))
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }

                        zonesCard
                        timeInputCard

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }

                        if let result = viewModel.resultText {
                            AppCard(title: "Result", accent: true) {
                                Text(result)
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(Color("AppAccent"))
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                    .scaleEffect(viewModel.resultScale)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.resultScale)
                            }
                        }

                        favoritesSection
                        historySection
                    }
                    SuccessCheckmarkOverlay(isVisible: $showSuccessCheck)
                }
            }
            .navigationTitle("Time Zone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                if scenePhase == .active {
                    clockDate = Date()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .dataReset)) { _ in
                viewModel.timeInput = ""
                viewModel.resultText = nil
                viewModel.errorMessage = nil
            }
        }
    }

    private var localTimeHero: some View {
        AppCard(accent: true) {
            HStack(spacing: 16) {
                AppIconBadge(systemName: "clock.fill", size: 56, highlighted: true)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Local Time")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text(clockDate, style: .time)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text(clockDate, format: .dateTime.weekday(.wide).month().day())
                        .font(.footnote)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
            }
        }
    }

    private var zonesCard: some View {
        AppCard(title: "Time Zones") {
            VStack(spacing: 14) {
                zonePickerRow(label: "From", selection: Binding(
                    get: { viewModel.fromZone },
                    set: { viewModel.fromZone = $0 }
                ))
                zonePickerRow(label: "To", selection: Binding(
                    get: { viewModel.toZone },
                    set: { viewModel.toZone = $0 }
                ))
                HStack(spacing: 10) {
                    pinButton(title: "Pin From", isOn: viewModel.isFavorite(viewModel.fromZone)) {
                        viewModel.toggleFavorite(viewModel.fromZone)
                    }
                    pinButton(title: "Pin To", isOn: viewModel.isFavorite(viewModel.toZone)) {
                        viewModel.toggleFavorite(viewModel.toZone)
                    }
                }
            }
        }
    }

    private var timeInputCard: some View {
        AppCard(title: "Convert") {
            VStack(spacing: 12) {
                AppStyledTextField(placeholder: "Enter Time (HH:MM)", text: $viewModel.timeInput)
                    .keyboardType(.numbersAndPunctuation)
                    .shake(trigger: viewModel.shakeTrigger)
                Button("Convert") {
                    viewModel.convert()
                    if viewModel.resultText != nil {
                        SuccessCheckmarkOverlay.show(binding: $showSuccessCheck)
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }

    private func zonePickerRow(label: String, selection: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color("AppTextSecondary"))
                .frame(width: 48, alignment: .leading)
            Picker(label, selection: selection) {
                ForEach(viewModel.sortedZoneIdentifiers, id: \.self) { zone in
                    Text(viewModel.displayName(for: zone)).tag(zone)
                }
            }
            .pickerStyle(.menu)
            .tint(Color("AppPrimary"))
        }
        .padding(12)
        .appInsetSurface(cornerRadius: 12)
    }

    private func pinButton(title: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: isOn ? "star.fill" : "star")
                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(isOn ? Color("AppBackground") : Color("AppTextPrimary"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isOn ? AnyShapeStyle(AppGradients.primary) : AnyShapeStyle(AppGradients.surfaceInset))
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .appShadow(level: isOn ? .subtle : .none)
        }
        .buttonStyle(.plain)
    }

    private var favoritesSection: some View {
        Group {
            if !storage.favoriteTimeZones.isEmpty {
                AppCard(title: "Favorites") {
                    VStack(spacing: 8) {
                        ForEach(storage.favoriteTimeZones, id: \.self) { zone in
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(Color("AppPrimary"))
                                    .font(.caption)
                                Text(viewModel.displayName(for: zone))
                                    .font(.subheadline)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
        }
    }

    private var historySection: some View {
        Group {
            if !storage.conversionHistory.isEmpty {
                AppCard(title: "Recent Conversions", trailing: "Tap to repeat") {
                    VStack(spacing: 8) {
                        ForEach(storage.conversionHistory.prefix(12)) { record in
                            Button {
                                viewModel.applyHistory(record)
                            } label: {
                                AppHistoryCell(
                                    primary: "\(record.originalTime) → \(record.convertedTime)",
                                    secondary: "\(record.fromZone) → \(record.toZone)",
                                    relativeDate: record.createdAt,
                                    icon: "globe"
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

private struct WorldMapIllustration: View {
    var body: some View {
        ZStack {
            Ellipse()
                .stroke(Color("AppPrimary").opacity(0.5), lineWidth: 2)
                .frame(width: 200, height: 120)
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: "clock.fill")
                    .font(.title2)
                    .foregroundStyle(Color("AppAccent"))
                    .offset(
                        x: CGFloat([-50, 0, 50][index]),
                        y: CGFloat([-20, 30, -10][index])
                    )
            }
            Path { path in
                path.move(to: CGPoint(x: 40, y: 60))
                path.addQuadCurve(to: CGPoint(x: 160, y: 60), control: CGPoint(x: 100, y: 20))
            }
            .stroke(Color("AppPrimary"), style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
        }
    }
}
