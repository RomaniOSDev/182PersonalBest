import SwiftUI
import UIKit

enum AppTheme {
    static let background = Color(hex: "#F4F6FA")
    static let accent = Color(hex: "#4A91D6")
    static let textPrimary = Color(hex: "#153254")
    static let textSecondary = Color(hex: "#8E9AAB")
    static let cardBackground = Color(hex: "#FFFFFF")
    static let fieldBackground = Color(hex: "#E8ECF2")

    static let cornerRadius: CGFloat = 18
    static let cornerRadiusSmall: CGFloat = 12

    static func formattedValue(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        }
        return String(format: "%.1f", value)
    }

    static func percentText(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }

    static func accentGradient(_ color: Color = accent) -> LinearGradient {
        LinearGradient(
            colors: [color, color.opacity(0.78)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func cardGradient(accent: Color = accent) -> LinearGradient {
        LinearGradient(
            colors: [accent.opacity(0.10), cardBackground, cardBackground],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func screenGradient() -> LinearGradient {
        LinearGradient(
            colors: [accent.opacity(0.07), background, background],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

enum AppElevation {
    case flat
    case soft
    case medium
    case hero

    var radius: CGFloat {
        switch self {
        case .flat: return 0
        case .soft: return 6
        case .medium: return 10
        case .hero: return 14
        }
    }

    var y: CGFloat {
        switch self {
        case .flat: return 0
        case .soft: return 2
        case .medium: return 4
        case .hero: return 8
        }
    }

    func shadowColor(accent: Color) -> Color {
        switch self {
        case .flat: return .clear
        case .soft: return Color.black.opacity(0.05)
        case .medium: return Color.black.opacity(0.08)
        case .hero: return accent.opacity(0.22)
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let red, green, blue, alpha: Double
        switch hex.count {
        case 6:
            red = Double((int >> 16) & 0xFF) / 255
            green = Double((int >> 8) & 0xFF) / 255
            blue = Double(int & 0xFF) / 255
            alpha = 1
        case 8:
            red = Double((int >> 24) & 0xFF) / 255
            green = Double((int >> 16) & 0xFF) / 255
            blue = Double((int >> 8) & 0xFF) / 255
            alpha = Double(int & 0xFF) / 255
        default:
            red = 0
            green = 0
            blue = 0
            alpha = 1
        }

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let red, green, blue, alpha: CGFloat
        switch hex.count {
        case 6:
            red = CGFloat((int >> 16) & 0xFF) / 255
            green = CGFloat((int >> 8) & 0xFF) / 255
            blue = CGFloat(int & 0xFF) / 255
            alpha = 1
        case 8:
            red = CGFloat((int >> 24) & 0xFF) / 255
            green = CGFloat((int >> 16) & 0xFF) / 255
            blue = CGFloat((int >> 8) & 0xFF) / 255
            alpha = CGFloat(int & 0xFF) / 255
        default:
            red = 0
            green = 0
            blue = 0
            alpha = 1
        }

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

extension Date {
    var recordDisplayString: String {
        AppFormatters.recordDate.string(from: self)
    }
}

enum AppFormatters {
    static let recordDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()
}

// MARK: - Optimized surface modifiers
// One composited shadow per card — avoids multi-pass blur in scrolling lists.

struct AppCardSurface: ViewModifier {
    var accent: Color = AppTheme.accent
    var elevation: AppElevation = .soft
    var cornerRadius: CGFloat = AppTheme.cornerRadius
    var useGradient: Bool = true
    var bordered: Bool = true

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        useGradient
                            ? AnyShapeStyle(AppTheme.cardGradient(accent: accent))
                            : AnyShapeStyle(AppTheme.cardBackground)
                    )
                    .overlay {
                        if bordered {
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [accent.opacity(0.22), accent.opacity(0.06)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        }
                    }
            }
            .compositingGroup()
            .shadow(
                color: elevation.shadowColor(accent: accent),
                radius: elevation.radius,
                y: elevation.y
            )
    }
}

struct AppFlatSurface: ViewModifier {
    var accent: Color = AppTheme.accent
    var cornerRadius: CGFloat = AppTheme.cornerRadiusSmall

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppTheme.cardBackground)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(accent.opacity(0.10), lineWidth: 1)
                    }
            }
    }
}

extension View {
    func appCard(
        accent: Color = AppTheme.accent,
        elevation: AppElevation = .soft,
        cornerRadius: CGFloat = AppTheme.cornerRadius,
        useGradient: Bool = true
    ) -> some View {
        modifier(AppCardSurface(
            accent: accent,
            elevation: elevation,
            cornerRadius: cornerRadius,
            useGradient: useGradient
        ))
    }

    func appFlatCard(accent: Color = AppTheme.accent, cornerRadius: CGFloat = AppTheme.cornerRadiusSmall) -> some View {
        modifier(AppFlatSurface(accent: accent, cornerRadius: cornerRadius))
    }

    func screenBackground() -> some View {
        background {
            AppTheme.screenGradient()
                .ignoresSafeArea()
        }
    }
}

struct AppProgressBar: View {
    let progress: Double
    let tint: Color
    var height: CGFloat = 10
    var isComplete: Bool = false

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(tint.opacity(0.14))

            Capsule()
                .fill(
                    LinearGradient(
                        colors: isComplete
                            ? [AppTheme.accent, AppTheme.accent.opacity(0.75)]
                            : [tint, tint.opacity(0.72)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .scaleEffect(x: max(clampedProgress, 0.04), y: 1, anchor: .leading)
        }
        .frame(height: height)
    }
}

struct AppPrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppTheme.accentGradient())
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall, style: .continuous))
            .compositingGroup()
            .shadow(color: AppTheme.accent.opacity(0.28), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

struct AppSecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background {
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall, style: .continuous)
                        .fill(AppTheme.cardBackground)
                        .overlay {
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall, style: .continuous)
                                .strokeBorder(AppTheme.textPrimary.opacity(0.18), lineWidth: 1.5)
                        }
                }
                .foregroundStyle(AppTheme.textPrimary)
        }
        .buttonStyle(.plain)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String?
    var buttonAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(AppTheme.accent.opacity(0.25))
                    .frame(width: 96, height: 96)
                    .overlay {
                        Circle()
                            .strokeBorder(AppTheme.accent.opacity(0.15), lineWidth: 1)
                    }

                Image(systemName: icon)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(AppTheme.accent)
            }
            .compositingGroup()
            .shadow(color: AppTheme.accent.opacity(0.15), radius: 10, y: 4)

            VStack(spacing: 8) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            if let buttonTitle, let buttonAction {
                AppPrimaryButton(buttonTitle, icon: "plus", action: buttonAction)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 40)
    }
}

struct SectionHeaderView: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(AppTheme.textPrimary)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CategoryIconBadge: View {
    let category: ExerciseCategory
    var size: CGFloat = 48
    var elevated: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .fill(AppTheme.accentGradient())
                .frame(width: size, height: size)

            Image(systemName: category.iconName)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(.white)
        }
        .modifier(OptionalBadgeShadow(enabled: elevated, color: AppTheme.accent))
    }
}

private struct OptionalBadgeShadow: ViewModifier {
    let enabled: Bool
    let color: Color

    func body(content: Content) -> some View {
        if enabled {
            content
                .compositingGroup()
                .shadow(color: color.opacity(0.25), radius: 6, y: 3)
        } else {
            content
        }
    }
}

struct AppFormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.textSecondary)
                .textCase(.uppercase)

            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .padding(14)
                .background {
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall, style: .continuous)
                        .fill(AppTheme.fieldBackground)
                        .overlay {
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall, style: .continuous)
                                .strokeBorder(AppTheme.accent.opacity(0.08), lineWidth: 1)
                        }
                }
                .foregroundStyle(AppTheme.textPrimary)
        }
    }
}

struct MiniProgressRing: View {
    let progress: Double
    var tint: Color = AppTheme.accent

    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.15), lineWidth: 4)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(tint, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text(AppTheme.percentText(progress))
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(tint)
        }
        .frame(width: 44, height: 44)
    }
}
