import SwiftUI

enum HomeWidgetAccent {
    case blue, coral, green, navy

    var color: Color {
        AppTheme.accent
    }

    static func from(_ raw: String) -> HomeWidgetAccent {
        switch raw {
        case "coral": return .coral
        case "green": return .green
        case "navy": return .navy
        default: return .blue
        }
    }
}

struct HomeHeroBannerView: View {
    let greeting: String
    let highlight: String
    let recordsThisMonth: Int

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("HomeHeroBanner")
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()

            LinearGradient(
                colors: [.clear, AppTheme.textPrimary.opacity(0.08), AppTheme.textPrimary.opacity(0.78)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(greeting)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.9))

                Text("Your Progress Hub")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)

                Text(highlight)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(2)

                if recordsThisMonth > 0 {
                    Label("\(recordsThisMonth) records this month", systemImage: "flame.fill")
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(.white.opacity(0.18)))
                        .foregroundStyle(.white)
                }
            }
            .padding(18)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .compositingGroup()
        .shadow(color: AppTheme.accent.opacity(0.20), radius: 12, y: 6)
    }
}

struct HomeStatWidget: View {
    let item: HomeStatItem

    private var accent: HomeWidgetAccent { HomeWidgetAccent.from(item.accent) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: item.icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(accent.color)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(AppTheme.accent.opacity(0.12)))
                Spacer()
            }

            Text(item.value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.textPrimary)
                Text(item.subtitle)
                    .font(.caption2)
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard(accent: AppTheme.accent, elevation: .soft, cornerRadius: AppTheme.cornerRadiusSmall)
    }
}

struct HomeQuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(Circle().fill(AppTheme.accentGradient()))
                    .compositingGroup()
                    .shadow(color: AppTheme.accent.opacity(0.25), radius: 5, y: 2)

                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .appFlatCard(accent: AppTheme.accent)
        }
        .buttonStyle(.plain)
    }
}

struct HomeGoalWidgetCard: View {
    let item: HomeGoalItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                CategoryIconBadge(category: item.exercise.category, size: 36)
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.exercise.name)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(1)
                    if let target = item.exercise.targetValue {
                        Text("\(AppTheme.formattedValue(item.exercise.currentRecordValue)) / \(AppTheme.formattedValue(target)) \(item.exercise.unit)")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }

            AppProgressBar(
                progress: item.progress,
                tint: AppTheme.accent,
                height: 8
            )

            Text(AppTheme.percentText(item.progress))
                .font(.caption2.weight(.bold))
                .foregroundStyle(AppTheme.accent)
        }
        .padding(14)
        .frame(width: 200)
        .appCard(accent: AppTheme.accent, elevation: .soft, cornerRadius: AppTheme.cornerRadiusSmall)
    }
}

struct HomeRecentActivityRow: View {
    let item: HomeRecentActivityItem

    var body: some View {
        HStack(spacing: 12) {
            CategoryIconBadge(category: item.category, size: 40)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.exerciseName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)
                    if item.isBest {
                        Image(systemName: "medal.fill")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.accent)
                    }
                }

                HStack(spacing: 4) {
                    Text("\(AppTheme.formattedValue(item.value)) \(item.unit)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.accent)
                    Text("•")
                        .foregroundStyle(AppTheme.textSecondary)
                    Text(item.date.recordDisplayString)
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }

            Spacer()
        }
        .padding(12)
        .appFlatCard(accent: AppTheme.accent)
    }
}

struct HomePinnedMiniCard: View {
    let exercise: Exercise

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                CategoryIconBadge(category: exercise.category, size: 32)
                Spacer()
                Image(systemName: "pin.fill")
                    .font(.caption2)
                    .foregroundStyle(AppTheme.accent)
            }

            Text(exercise.name)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(2)

            if exercise.hasRecords {
                Text("\(AppTheme.formattedValue(exercise.currentRecordValue)) \(exercise.unit)")
                    .font(.headline)
                    .foregroundStyle(AppTheme.accent)
            } else {
                Text("No records")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .padding(14)
        .frame(width: 140, height: 130)
        .appCard(accent: AppTheme.accent, elevation: .soft, cornerRadius: AppTheme.cornerRadiusSmall)
    }
}

struct HomeCategoryBannerView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "Train Every Way",
                subtitle: "Strength, cardio and flexibility in one place"
            )

            Image("HomeCategoryStrip")
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall, style: .continuous))
        }
        .padding(16)
        .appCard(elevation: .soft)
    }
}
