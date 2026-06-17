import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage

    private var accentColor: Color {
        AppTheme.accent
    }

    var body: some View {
        VStack(spacing: 28) {
            illustration
                .padding(.horizontal, 24)

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.title.weight(.bold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.body)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
            }
        }
        .padding(.top, 20)
    }

    @ViewBuilder
    private var illustration: some View {
        if let imageName = page.imageName {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 260)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                        .strokeBorder(accentColor.opacity(0.15), lineWidth: 1)
                }
                .compositingGroup()
                .shadow(color: accentColor.opacity(0.18), radius: 12, y: 6)
        } else {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [accentColor.opacity(0.22), accentColor.opacity(0.04)],
                            center: .center,
                            startRadius: 20,
                            endRadius: 140
                        )
                    )
                    .frame(width: 260, height: 260)

                VStack(spacing: 16) {
                    Image(systemName: page.icon)
                        .font(.system(size: 56, weight: .semibold))
                        .foregroundStyle(accentColor)

                    miniProgressPreview(accent: accentColor)
                }
            }
            .frame(height: 260)
        }
    }

    private func miniProgressPreview(accent: Color) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                ForEach(0..<4, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(accent.opacity(0.25 + Double(index) * 0.18))
                        .frame(width: 28, height: CGFloat(20 + index * 10))
                }
            }

            AppProgressBar(progress: 0.68, tint: accent, height: 8)
                .frame(width: 160)
        }
        .padding(20)
        .appFlatCard(accent: accent)
        .frame(width: 220)
    }
}

#Preview {
    OnboardingPageView(
        page: OnboardingPage(
            id: 1,
            title: "Watch Your Progress",
            subtitle: "Set goals and view charts.",
            icon: "chart.line.uptrend.xyaxis",
            accent: "green",
            imageName: nil
        )
    )
    .screenBackground()
}
