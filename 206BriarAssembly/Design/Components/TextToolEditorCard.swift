import SwiftUI

struct TextToolEditorCard: View {
    let title: String
    @Binding var text: String
    var minHeight: CGFloat = 120

    var body: some View {
        AppCard(title: title) {
            TextEditor(text: $text)
                .frame(minHeight: minHeight)
                .scrollContentBackground(.hidden)
                .foregroundStyle(Color("AppTextPrimary"))
        }
    }
}
