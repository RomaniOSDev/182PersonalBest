import SwiftUI

struct CategoryFilterBar: View {
    @Binding var selectedCategory: ExerciseCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                filterChip(
                    title: "All",
                    icon: "square.grid.2x2",
                    color: AppTheme.accent,
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }

                ForEach(ExerciseCategory.allCases) { category in
                    filterChip(
                        title: category.title,
                        icon: category.iconName,
                        color: category.themeColor,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func filterChip(
        title: String,
        icon: String,
        color: Color,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption.weight(.semibold))
                Text(title)
                    .font(.caption.weight(.bold))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background {
                Capsule()
                    .fill(
                        isSelected
                            ? AnyShapeStyle(AppTheme.accentGradient(color))
                            : AnyShapeStyle(AppTheme.cardBackground)
                    )
                    .overlay {
                        if !isSelected {
                            Capsule().strokeBorder(color.opacity(0.18), lineWidth: 1)
                        }
                    }
            }
            .foregroundStyle(isSelected ? Color.white : AppTheme.textPrimary)
        }
        .buttonStyle(.plain)
        .compositingGroup()
        .shadow(color: isSelected ? color.opacity(0.22) : .clear, radius: 6, y: 2)
    }
}
