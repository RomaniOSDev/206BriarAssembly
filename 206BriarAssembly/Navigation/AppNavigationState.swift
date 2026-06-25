import SwiftUI
import Combine

final class AppNavigationState: ObservableObject {
    @Published var selectedTab: AppTab = .workspace
    @Published var selectedSnippetID: UUID?

    func openWorkspace(withSnippet id: UUID? = nil) {
        selectedSnippetID = id
        selectedTab = .workspace
    }
}
