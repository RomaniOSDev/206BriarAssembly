import SwiftUI

struct HomeStatWidget: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color("AppPrimary"))
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(Color("AppAccent"))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
        .appCardSurface(cornerRadius: 16, shadow: .none)
    }
}

struct HomeFeatureWidget: View {
    let imageName: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.lightTap()
            action()
        }) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 100)
                        .frame(maxWidth: .infinity)
                        .clipped()
                    LinearGradient(
                        colors: [Color.clear, Color("AppBackground").opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 100)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppGradients.surface)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color("AppPrimary").opacity(0.3), lineWidth: 1)
            )
            .appShadow(level: .raised)
        }
        .buttonStyle(.plain)
    }
}

struct HomeQuickActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.lightTap()
            action()
        }) {
            VStack(spacing: 10) {
                AppIconBadge(systemName: icon, size: 44)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .appCardSurface(cornerRadius: 14, shadow: .none)
        }
        .buttonStyle(.plain)
    }
}

struct HomeActivityRow: View {
    let icon: String
    let title: String
    let detail: String
    var time: Date?

    var body: some View {
        HStack(spacing: 12) {
            AppIconBadge(systemName: icon, size: 40)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
            Spacer()
            if let time {
                Text(time, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .padding(12)
        .appInsetSurface(cornerRadius: 12)
    }
}

struct HomeProgressWidget: View {
    let unlocked: Int
    let total: Int
    let onTap: () -> Void

    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(unlocked) / Double(total)
    }

    var body: some View {
        Button(action: {
            HapticManager.lightTap()
            onTap()
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color("AppBackground").opacity(0.8), lineWidth: 8)
                        .frame(width: 64, height: 64)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(AppGradients.primary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 64, height: 64)
                        .rotationEffect(.degrees(-90))
                    Text("\(unlocked)")
                        .font(.headline.bold())
                        .foregroundStyle(Color("AppAccent"))
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Achievements")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("\(unlocked) of \(total) unlocked")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                    Text("Tap to view all badges")
                        .font(.caption2)
                        .foregroundStyle(Color("AppPrimary"))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(16)
            .appCardSurface(cornerRadius: 16, accent: true, shadow: .raised)
        }
        .buttonStyle(.plain)
    }
}
