import SwiftUI

struct RecordHeroView: View {
    let exercise: Exercise

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                CategoryIconBadge(category: exercise.category, size: 44, elevated: true)
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.category.title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(exercise.category.themeColor)
                    Text(exercise.recordType.title)
                        .font(.caption2)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                Spacer()
            }

            VStack(spacing: 6) {
                Text("Current Record")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(AppTheme.textSecondary)

                if exercise.records.isEmpty {
                    Text("—")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary.opacity(0.3))
                } else {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(AppTheme.formattedValue(exercise.currentRecordValue))
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                        Text(exercise.unit)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    Label(exercise.currentRecordDate.recordDisplayString, systemImage: "calendar.badge.clock")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .appCard(accent: exercise.category.themeColor, elevation: .hero)
    }
}
