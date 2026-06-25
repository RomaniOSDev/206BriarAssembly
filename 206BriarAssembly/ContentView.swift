//
//  ContentView.swift
//  206BriarAssembly
//

import SwiftUI

struct ContentView: View {
    @StateObject private var storage: AppStorage
    @StateObject private var workspaceViewModel: WorkspaceViewModel
    @StateObject private var libraryViewModel: LibraryViewModel
    @StateObject private var navigationState = AppNavigationState()

    init() {
        let storage = AppStorage()
        _storage = StateObject(wrappedValue: storage)
        _workspaceViewModel = StateObject(wrappedValue: WorkspaceViewModel(storage: storage))
        _libraryViewModel = StateObject(wrappedValue: LibraryViewModel(storage: storage))
    }

    var body: some View {
        Group {
            if storage.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(storage)
        .environmentObject(workspaceViewModel)
        .environmentObject(libraryViewModel)
        .environmentObject(navigationState)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
