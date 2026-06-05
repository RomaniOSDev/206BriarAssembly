import SwiftUI

struct AchievementBannerView: View {
    let title: String
    @State private var offset: CGFloat = -120

    var body: some View {
        VStack {
            HStack(spacing: 14) {
                AppIconBadge(systemName: "star.fill", size: 44, highlighted: true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Achievement Unlocked")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                Spacer(minLength: 0)
            }
            .padding(16)
            .appCardSurface(cornerRadius: 16, accent: true, shadow: .raised)
            .padding(.horizontal, 16)
            .offset(y: offset)
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                offset = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    offset = -120
                }
            }
        }
    }
}
