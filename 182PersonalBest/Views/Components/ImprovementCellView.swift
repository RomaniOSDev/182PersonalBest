import SwiftUI

struct ImprovementCellView: View {
    let improvement: ExerciseImprovement
    var category: ExerciseCategory = .strength

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppTheme.accentGradient(category.themeColor).opacity(0.2))
                    .frame(width: 46, height: 46)
                Image(systemName: "arrow.up.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(category.themeColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(improvement.exerciseName)
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                Text("\(improvement.deltaText) \(improvement.periodText)")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            Image(systemName: "chart.line.uptrend.xyaxis")
                .foregroundStyle(category.themeColor.opacity(0.6))
        }
        .padding(16)
        .appCard(accent: category.themeColor, elevation: .soft)
    }
}
