import SwiftUI

/// Lightweight gradients and elevation — one shadow per container, no Canvas, no blur filters.
enum AppGradients {
    static var screen: LinearGradient {
        LinearGradient(
            colors: [Color("AppBackground"), Color("AppSurface").opacity(0.55), Color("AppBackground")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var surface: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppSurface"),
                Color("AppSurface").opacity(0.92),
                Color("AppBackground").opacity(0.35)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var surfaceInset: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppBackground").opacity(0.7),
                Color("AppBackground").opacity(0.45)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var primary: LinearGradient {
        LinearGradient(
            colors: [Color("AppAccent"), Color("AppPrimary")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var primaryVertical: LinearGradient {
        LinearGradient(
            colors: [Color("AppPrimary"), Color("AppPrimary").opacity(0.82)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var edgeHighlight: LinearGradient {
        LinearGradient(
            colors: [Color("AppTextPrimary").opacity(0.14), Color.clear],
            startPoint: .top,
            endPoint: .center
        )
    }
}

enum AppShadowLevel {
    /// Lists and grids — gradient only, no shadow (GPU-friendly).
    case none
    /// Nested rows inside cards.
    case subtle
    /// Main cards and hero blocks — single shadow.
    case raised
}

extension View {
    func appCardSurface(
        cornerRadius: CGFloat = 16,
        accent: Bool = false,
        shadow: AppShadowLevel = .raised
    ) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        return self
            .background(
                shape.fill(AppGradients.surface)
            )
            .overlay(
                shape.fill(AppGradients.edgeHighlight)
                    .allowsHitTesting(false)
            )
            .overlay(
                shape.strokeBorder(
                    accent
                        ? Color("AppPrimary").opacity(0.5)
                        : Color("AppTextSecondary").opacity(0.14),
                    lineWidth: accent ? 1.5 : 1
                )
            )
            .clipShape(shape)
            .appShadow(level: shadow)
    }

    @ViewBuilder
    func appShadow(level: AppShadowLevel) -> some View {
        switch level {
        case .none:
            self
        case .subtle:
            self.shadow(color: Color("AppBackground").opacity(0.45), radius: 3, y: 1)
        case .raised:
            self.shadow(color: Color("AppBackground").opacity(0.55), radius: 8, y: 4)
        }
    }

    func appInsetSurface(cornerRadius: CGFloat = 12) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        return self
            .background(shape.fill(AppGradients.surfaceInset))
            .overlay(
                shape.strokeBorder(Color("AppTextSecondary").opacity(0.12), lineWidth: 1)
            )
            .clipShape(shape)
    }
}

/// Static ambient glow — fixed layout, no redraw loops.
struct AppAmbientGlow: View {
    var body: some View {
        GeometryReader { proxy in
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color("AppPrimary").opacity(0.22), Color.clear],
                        center: .center,
                        startRadius: 8,
                        endRadius: max(proxy.size.width, proxy.size.height) * 0.45
                    )
                )
                .frame(width: proxy.size.width * 0.9, height: proxy.size.width * 0.9)
                .offset(x: proxy.size.width * 0.55, y: -proxy.size.height * 0.08)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color("AppAccent").opacity(0.12), Color.clear],
                        center: .center,
                        startRadius: 4,
                        endRadius: proxy.size.width * 0.35
                    )
                )
                .frame(width: proxy.size.width * 0.65, height: proxy.size.width * 0.65)
                .offset(x: -proxy.size.width * 0.35, y: proxy.size.height * 0.55)
        }
        .allowsHitTesting(false)
    }
}
