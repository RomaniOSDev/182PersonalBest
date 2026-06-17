import SwiftUI

struct WorkoutSessionCellView: View {
    let session: WorkoutSession
    let exerciseName: (UUID) -> String
    let exerciseUnit: (UUID) -> String
    let exerciseCategory: (UUID) -> ExerciseCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Label(session.date.recordDisplayString, systemImage: "calendar")
                        .font(.headline)
                        .foregroundStyle(AppTheme.textPrimary)

                    if let note = session.note, !note.isEmpty {
                        Text(note)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("\(session.entries.count)")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(AppTheme.accent)
                    Text("records")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(AppTheme.accent.opacity(0.10))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(AppTheme.accent.opacity(0.18), lineWidth: 1)
                        }
                )
            }

            Divider().opacity(0.4)

            VStack(spacing: 8) {
                ForEach(session.entries) { entry in
                    HStack(spacing: 12) {
                        CategoryIconBadge(category: exerciseCategory(entry.exerciseId), size: 34)

                        Text(exerciseName(entry.exerciseId))
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(AppTheme.textPrimary)
                            .lineLimit(1)

                        Spacer()

                        Text("\(AppTheme.formattedValue(entry.value)) \(exerciseUnit(entry.exerciseId))")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(exerciseCategory(entry.exerciseId).themeColor)
                    }
                }
            }
        }
        .padding(16)
        .appCard(elevation: .medium)
    }
}
