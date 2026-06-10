import SwiftUI

// MARK: - Card

struct AppCard<Content: View>: View {
    var title: String?
    var trailing: String?
    var accent: Bool = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let title {
                AppSectionHeader(title: title, trailing: trailing)
            }
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardSurface(cornerRadius: 16, accent: accent, shadow: .raised)
    }
}

// MARK: - Section header

struct AppSectionHeader: View {
    let title: String
    var trailing: String?

    var body: some View {
        HStack {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppAccent"))
            }
        }
    }
}

// MARK: - Icon badge

struct AppIconBadge: View {
    let systemName: String
    var size: CGFloat = 44
    var highlighted: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.27, style: .continuous)
                .fill(
                    highlighted
                        ? AnyShapeStyle(AppGradients.primary)
                        : AnyShapeStyle(
                            LinearGradient(
                                colors: [
                                    Color("AppPrimary").opacity(0.28),
                                    Color("AppPrimary").opacity(0.12)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .frame(width: size, height: size)
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.27, style: .continuous)
                        .strokeBorder(Color("AppPrimary").opacity(highlighted ? 0.4 : 0.2), lineWidth: 1)
                )
            Image(systemName: systemName)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(highlighted ? Color("AppBackground") : Color("AppPrimary"))
        }
        .appShadow(level: highlighted ? .subtle : .none)
    }
}

// MARK: - Navigation cell

struct AppNavigationCell: View {
    let icon: String
    let title: String
    let subtitle: String
    var showChevron: Bool = true

    var body: some View {
        HStack(spacing: 14) {
            AppIconBadge(systemName: icon)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
            Spacer(minLength: 8)
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .padding(14)
        .frame(minHeight: 44)
        .appCardSurface(cornerRadius: 14, shadow: .none)
    }
}

// MARK: - Action row (settings style)

struct AppActionRow: View {
    let icon: String
    let title: String
    var subtitle: String?
    var destructive: Bool = false
    var showChevron: Bool = true

    var body: some View {
        HStack(spacing: 14) {
            AppIconBadge(systemName: icon, size: 40, highlighted: !destructive && icon == "star.fill")
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(destructive ? .red : Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            Spacer()
            if showChevron && !destructive {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(minHeight: 44)
    }
}

// MARK: - Metric tile

struct AppMetricTile: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
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
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .appInsetSurface(cornerRadius: 12)
    }
}

// MARK: - Chip

struct AppChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background {
                    if isSelected {
                        Capsule().fill(AppGradients.primary)
                    } else {
                        Capsule().fill(AppGradients.surface)
                    }
                }
                .foregroundStyle(isSelected ? Color("AppBackground") : Color("AppTextPrimary"))
                .overlay(
                    Capsule()
                        .strokeBorder(
                            Color("AppTextSecondary").opacity(isSelected ? 0 : 0.2),
                            lineWidth: 1
                        )
                )
                .appShadow(level: isSelected ? .subtle : .none)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Empty state

struct AppEmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var imageName: String?

    var body: some View {
        VStack(spacing: 16) {
            if let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 220, maxHeight: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(Color("AppPrimary").opacity(0.2), lineWidth: 1)
                    )
            } else {
                AppIconBadge(systemName: icon, size: 72, highlighted: true)
            }
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .multilineTextAlignment(.center)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}

// MARK: - Styled field

struct AppStyledTextField: View {
    let placeholder: String
    @Binding var text: String
    var axis: Axis = .horizontal
    var lineLimit: ClosedRange<Int>?

    var body: some View {
        Group {
            if let lineLimit, axis == .vertical {
                TextField(placeholder, text: $text, axis: .vertical)
                    .lineLimit(lineLimit)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding(14)
        .appInsetSurface(cornerRadius: 12)
        .foregroundStyle(Color("AppTextPrimary"))
    }
}

// MARK: - Snippet cell

struct AppSnippetCell: View {
    let tag: String
    let date: Date
    let preview: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(AppGradients.primaryVertical)
                .frame(width: 4)
                .padding(.vertical, 4)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(tag)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color("AppPrimary"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color("AppPrimary").opacity(0.18))
                        .clipShape(Capsule())
                    Spacer()
                    Text(date, style: .date)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Text(preview)
                    .font(.body)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(14)
        .appCardSurface(cornerRadius: 14, shadow: .none)
    }
}

// MARK: - History cell

struct AppHistoryCell: View {
    let primary: String
    let secondary: String
    let relativeDate: Date
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            AppIconBadge(systemName: icon, size: 40)
            VStack(alignment: .leading, spacing: 4) {
                Text(primary)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppAccent"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(secondary)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                Text(relativeDate, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            Spacer()
            Image(systemName: "arrow.clockwise")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color("AppPrimary"))
        }
        .padding(12)
        .appInsetSurface(cornerRadius: 12)
    }
}

// MARK: - Screen scroll wrapper

struct AppScreenScroll<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 18) {
                content()
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
    }
}

// MARK: - Formatter action cell

struct AppFormatterActionCell: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                AppIconBadge(systemName: icon, size: 40)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .appCardSurface(cornerRadius: 12, shadow: .none)
        }
        .buttonStyle(.plain)
    }
}
