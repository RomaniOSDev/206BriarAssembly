import SwiftUI

struct AppBackgroundView<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            AppGradients.screen
            AppAmbientGlow()
            content()
        }
        .background(Color("AppBackground"))
    }
}
