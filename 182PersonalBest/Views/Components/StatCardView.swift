import SwiftUI

struct StatCardView: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    var accent: Color = AppTheme.accent

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(accent.opacity(0.14))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(accent)
                }
                Spacer()
            }

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard(accent: accent, elevation: .soft)
    }
}

#Preview {
    HStack {
        StatCardView(title: "This Month", value: "12", subtitle: "Records", icon: "calendar")
        StatCardView(title: "Growth", value: "+8.5", subtitle: "Average", icon: "arrow.up", accent: AppTheme.accent)
    }
    .padding()
    .screenBackground()
}
