import SwiftUI

struct ExerciseCellView: View {
    let exercise: Exercise

    var body: some View {
        HStack(spacing: 14) {
            CategoryIconBadge(category: exercise.category, size: 52)

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Text(exercise.name)
                        .font(.headline)
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(1)

                    if exercise.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.accent)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(AppTheme.accent.opacity(0.12)))
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.tertiary)
                }

                HStack(spacing: 6) {
                    Text(exercise.category.title)
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(exercise.category.themeColor.opacity(0.12)))
                        .foregroundStyle(exercise.category.themeColor)

                    Text(exercise.recordType.title)
                        .font(.caption2)
                        .foregroundStyle(AppTheme.textSecondary)
                }

                if exercise.records.isEmpty {
                    Label("No records yet", systemImage: "plus.circle")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                } else {
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(AppTheme.formattedValue(exercise.currentRecordValue))
                                    .font(.title2.weight(.bold))
                                    .foregroundStyle(exercise.category.themeColor)
                                Text(exercise.unit)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(AppTheme.textPrimary)
                            }

                            Label(exercise.currentRecordDate.recordDisplayString, systemImage: "calendar")
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                        }

                        Spacer()

                        if let progress = exercise.goalProgress {
                            MiniProgressRing(
                                progress: progress,
                                tint: AppTheme.accent
                            )
                        } else {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.title3)
                                .foregroundStyle(exercise.category.themeColor.opacity(0.7))
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(exercise.category.themeColor.opacity(0.10)))
                        }
                    }
                }
            }
        }
        .padding(16)
        .appCard(accent: exercise.category.themeColor, elevation: .medium)
    }
}
