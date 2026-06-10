import SwiftUI
import StoreKit
import UIKit
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject private var storage: AppStorage
    @State private var showResetAlert = false
    @State private var showImporter = false
    @State private var showShareSheet = false
    @State private var exportURL: URL?
    @State private var importError: String?
    @State private var importSuccess = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            AppBackgroundView {
                AppScreenScroll {
                    AppCard(title: "Library Overview") {
                        HStack(spacing: 10) {
                            AppMetricTile(
                                value: "\(storage.snippetCount)",
                                label: "Snippets",
                                icon: "books.vertical.fill"
                            )
                            AppMetricTile(
                                value: "\(storage.savedPipelines.count)",
                                label: "Presets",
                                icon: "arrow.triangle.branch"
                            )
                        }
                    }

                    AppCard(title: "Legal") {
                        VStack(spacing: 0) {
                            actionButton(icon: "star.fill", title: "Rate Us", subtitle: "Leave a review on the App Store") {
                                rateApp()
                            }
                            rowDivider
                            actionButton(icon: "hand.raised.fill", title: "Privacy", subtitle: "Privacy policy") {
                                openPrivacyPolicy()
                            }
                            rowDivider
                            actionButton(icon: "doc.text.fill", title: "Terms", subtitle: "Terms of service") {
                                openTerms()
                            }
                        }
                    }

                    AppCard(title: "Data") {
                        VStack(spacing: 0) {
                            actionButton(icon: "square.and.arrow.up.fill", title: "Export Backup", subtitle: "Snippets and pipeline presets") {
                                exportBackup()
                            }
                            rowDivider
                            actionButton(icon: "square.and.arrow.down.fill", title: "Import Backup", subtitle: "Restore from JSON") {
                                showImporter = true
                            }
                            rowDivider
                            Button {
                                HapticManager.lightTap()
                                showResetAlert = true
                            } label: {
                                AppActionRow(
                                    icon: "trash.fill",
                                    title: "Reset All Data",
                                    subtitle: "Erase snippets and presets",
                                    destructive: true,
                                    showChevron: false
                                )
                            }
                        }
                    }

                    Text("Version \(appVersion)")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { HapticManager.lightTap() }
                Button("Reset", role: .destructive) {
                    storage.resetAllData()
                    HapticManager.warning()
                }
            } message: {
                Text("This will erase all snippets and pipeline presets. This cannot be undone.")
            }
            .fileImporter(isPresented: $showImporter, allowedContentTypes: [.json], allowsMultipleSelection: false) { result in
                handleImport(result)
            }
            .sheet(isPresented: $showShareSheet, onDismiss: { exportURL = nil }) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            }
            .alert("Import Complete", isPresented: $importSuccess) {
                Button("OK", role: .cancel) { HapticManager.lightTap() }
            } message: {
                Text("Your backup was restored successfully.")
            }
            .alert("Import Failed", isPresented: Binding(
                get: { importError != nil },
                set: { if !$0 { importError = nil } }
            )) {
                Button("OK", role: .cancel) { importError = nil }
            } message: {
                Text(importError ?? "Unknown error")
            }
        }
    }

    private var rowDivider: some View {
        Rectangle()
            .fill(Color("AppBackground").opacity(0.6))
            .frame(height: 1)
            .padding(.leading, 54)
    }

    private func actionButton(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button {
            HapticManager.lightTap()
            action()
        } label: {
            AppActionRow(icon: icon, title: title, subtitle: subtitle)
        }
    }

    private func openPrivacyPolicy() {
        if let url = AppLink.privacyPolicy.url {
            UIApplication.shared.open(url)
        }
    }

    private func openTerms() {
        if let url = AppLink.termsOfService.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private func exportBackup() {
        do {
            let data = try storage.exportBackupData()
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("snippet-workspace-backup-\(Int(Date().timeIntervalSince1970)).json")
            try data.write(to: url)
            exportURL = url
            showShareSheet = true
            HapticManager.completeAction()
        } catch {
            importError = "Could not create backup file."
        }
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .failure(let error):
            importError = error.localizedDescription
            HapticManager.warning()
        case .success(let urls):
            guard let url = urls.first else {
                importError = "No file selected."
                return
            }
            guard url.startAccessingSecurityScopedResource() else {
                importError = "Cannot access selected file."
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            do {
                let data = try Data(contentsOf: url)
                try storage.importBackupData(data)
                importSuccess = true
                HapticManager.completeAction()
            } catch {
                importError = "Invalid backup file."
                HapticManager.warning()
            }
        }
    }
}
