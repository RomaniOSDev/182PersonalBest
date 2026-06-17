import SwiftUI

struct FormSectionCard<Content: View>: View {
    let title: String
    var subtitle: String?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }

            content
        }
        .padding(16)
        .appCard(elevation: .soft)
    }
}

struct CategorySelectionGrid: View {
    @Binding var selection: ExerciseCategory

    var body: some View {
        HStack(spacing: 10) {
            ForEach(ExerciseCategory.allCases) { category in
                Button {
                    withAnimation(.spring(response: 0.3)) { selection = category }
                } label: {
                    VStack(spacing: 8) {
                        CategoryIconBadge(category: category, size: 44)
                            .opacity(selection == category ? 1 : 0.45)
                        Text(category.title)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(selection == category ? AppTheme.accent : AppTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(selection == category ? category.themeColor.opacity(0.1) : Color.clear)
                    )
                    .overlay {
                        if selection == category {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(category.themeColor.opacity(0.4), lineWidth: 1.5)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct RecordTypeSelector: View {
    @Binding var selection: RecordComparisonType

    var body: some View {
        HStack(spacing: 10) {
            ForEach(RecordComparisonType.allCases) { type in
                Button {
                    selection = type
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: type == .higherIsBetter ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                            .font(.title2)
                        Text(type.title)
                            .font(.caption.weight(.semibold))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(selection == type ? AppTheme.accent.opacity(0.12) : AppTheme.fieldBackground)
                    )
                    .overlay {
                        if selection == type {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(AppTheme.accent, lineWidth: 1.5)
                        }
                    }
                    .foregroundStyle(selection == type ? AppTheme.accent : AppTheme.textPrimary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct WorkoutEntryCell: View {
    let exercise: Exercise
    @Binding var valueText: String
    @Binding var note: String
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                CategoryIconBadge(category: exercise.category, size: 36)
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(.headline)
                        .foregroundStyle(AppTheme.textPrimary)
                    Text(exercise.unit)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                Spacer()
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }

            AppFormField(
                title: "Value",
                placeholder: "Enter result",
                text: $valueText,
                keyboardType: .decimalPad
            )

            AppFormField(
                title: "Note",
                placeholder: "Optional note",
                text: $note
            )
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall, style: .continuous)
                .fill(exercise.category.themeColor.opacity(0.06))
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall, style: .continuous)
                .strokeBorder(exercise.category.themeColor.opacity(0.15), lineWidth: 1)
        }
    }
}
