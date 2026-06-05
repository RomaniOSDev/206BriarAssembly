//
//  ContentView.swift
//  206BriarAssembly
//

import SwiftUI

struct ContentView: View {
    @StateObject private var storage = AppStorage()

    var body: some View {
        Group {
            if storage.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .environmentObject(storage)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
