import SwiftUI

struct GoalProgressView: View {
    let exercise: Exercise
    var compact: Bool = false

    var body: some View {
        if let target = exercise.targetValue, let progress = exercise.goalProgress {
            VStack(alignment: .leading, spacing: compact ? 6 : 10) {
                HStack {
                    Label("Goal Progress", systemImage: "target")
                        .font(compact ? .caption.weight(.semibold) : .subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                    Spacer()
                    Text(goalLabel(target: target))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }

                AppProgressBar(
                    progress: progress,
                    tint: exercise.category.themeColor,
                    height: compact ? 8 : 10,
                    isComplete: exercise.isGoalReached
                )

                if exercise.isGoalReached {
                    Label("Goal reached!", systemImage: "checkmark.seal.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.accent)
                }
            }
            .padding(compact ? 0 : 16)
            .if(!compact) { view in
                view.appCard(accent: exercise.category.themeColor, elevation: .soft)
            }
        }
    }

    private func goalLabel(target: Double) -> String {
        if exercise.hasRecords {
            return "\(AppTheme.formattedValue(exercise.currentRecordValue)) / \(AppTheme.formattedValue(target)) \(exercise.unit)"
        }
        return "Target: \(AppTheme.formattedValue(target)) \(exercise.unit)"
    }
}

private extension View {
    @ViewBuilder
    func `if`(_ condition: Bool, transform: (Self) -> some View) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
