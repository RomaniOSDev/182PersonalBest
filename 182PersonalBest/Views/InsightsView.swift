import SwiftUI

struct InsightsView: View {
    @StateObject private var viewModel = InsightsViewModel()
    @ObservedObject private var storage = ExerciseStorageService.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if storage.exercises.isEmpty {
                        EmptyStateView(
                            icon: "chart.bar.doc.horizontal",
                            title: "No data yet",
                            message: "Add exercises and records to unlock insights about your progress."
                        )
                        .padding(.top, 60)
                    } else {
                        summaryGrid
                        improvementsSection
                    }
                }
                .padding(16)
                .padding(.bottom, 20)
            }
            .screenBackground()
            .navigationTitle("Insights")
            .onChange(of: storage.exercises) { _ in
                viewModel.refresh()
            }
            .onAppear {
                viewModel.refresh()
            }
        }
    }

    private var summaryGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Overview", subtitle: "Your activity at a glance")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCardView(
                    title: "This Month",
                    value: "\(viewModel.summary.recordsThisMonth)",
                    subtitle: "Records logged",
                    icon: "calendar"
                )

                StatCardView(
                    title: "Avg Growth",
                    value: viewModel.summary.averageImprovementText,
                    subtitle: "Per exercise",
                    icon: "arrow.up.forward",
                    accent: AppTheme.accent
                )
            }

            if let bestMonth = viewModel.summary.bestMonth {
                StatCardView(
                    title: "Best Month",
                    value: bestMonth.monthTitle,
                    subtitle: "\(bestMonth.count) records logged",
                    icon: "star.fill",
                    accent: AppTheme.accent
                )
            }
        }
    }

    private var improvementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: "First vs Latest",
                subtitle: "Compare your starting point with today"
            )

            if viewModel.summary.improvements.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title2)
                        .foregroundStyle(AppTheme.accent.opacity(0.5))
                    Text("Add at least 2 records per exercise to compare progress.")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .appCard(elevation: .soft)
            } else {
                ForEach(viewModel.summary.improvements) { item in
                    let category = storage.exercise(with: item.id)?.category ?? .strength
                    ImprovementCellView(improvement: item, category: category)
                }
            }
        }
    }
}

#Preview {
    InsightsView()
}
