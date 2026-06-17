import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Int
    @StateObject private var viewModel = HomeViewModel()
    @ObservedObject private var storage = ExerciseStorageService.shared

    @State private var showingAddExercise = false
    @State private var showingAddWorkout = false
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: 20) {
                    HomeHeroBannerView(
                        greeting: viewModel.greeting,
                        highlight: viewModel.highlightText,
                        recordsThisMonth: viewModel.recordsThisMonth
                    )

                    quickActions

                    if viewModel.hasData {
                        statsGrid
                        pinnedSection
                        goalsSection
                        recentSection
                        HomeCategoryBannerView()
                    } else {
                        emptyPrompt
                        HomeCategoryBannerView()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
            .screenBackground()
            .navigationTitle("Home")
            .navigationDestination(for: UUID.self) { exerciseId in
                RecordHistoryView(exerciseId: exerciseId)
            }
            .onChange(of: storage.exercises) { _ in viewModel.refresh() }
            .onChange(of: storage.workoutSessions) { _ in viewModel.refresh() }
            .onAppear { viewModel.refresh() }
            .sheet(isPresented: $showingAddExercise) {
                ExerciseFormView()
            }
            .sheet(isPresented: $showingAddWorkout) {
                WorkoutFormView()
            }
        }
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Quick Actions", subtitle: "Jump right in")

            HStack(spacing: 10) {
                HomeQuickActionButton(
                    title: "Add Exercise",
                    icon: "plus",
                    color: AppTheme.accent
                ) {
                    showingAddExercise = true
                }

                HomeQuickActionButton(
                    title: "Log Workout",
                    icon: "figure.run",
                    color: AppTheme.accent
                ) {
                    showingAddWorkout = true
                }

                HomeQuickActionButton(
                    title: "Insights",
                    icon: "chart.bar.fill",
                    color: AppTheme.accent
                ) {
                    selectedTab = 2
                }
            }
        }
    }

    private var statsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Overview", subtitle: "Your stats at a glance")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.stats) { stat in
                    HomeStatWidget(item: stat)
                }
            }
        }
    }

    @ViewBuilder
    private var pinnedSection: some View {
        if !viewModel.pinnedExercises.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeaderView(title: "Pinned", subtitle: "Your favorites")

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.pinnedExercises) { exercise in
                            HomePinnedMiniCard(exercise: exercise)
                                .onTapGesture {
                                    navigationPath.append(exercise.id)
                                }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var goalsSection: some View {
        if !viewModel.goalItems.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeaderView(title: "Active Goals", subtitle: "Almost there")

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.goalItems) { item in
                            HomeGoalWidgetCard(item: item)
                                .onTapGesture {
                                    navigationPath.append(item.exercise.id)
                                }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var recentSection: some View {
        if !viewModel.recentActivity.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    SectionHeaderView(title: "Recent Activity", subtitle: "Latest records")
                    Spacer()
                    Button("See All") {
                        selectedTab = 1
                    }
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.accent)
                }

                VStack(spacing: 8) {
                    ForEach(viewModel.recentActivity) { item in
                        HomeRecentActivityRow(item: item)
                            .onTapGesture {
                                navigationPath.append(item.exerciseId)
                            }
                    }
                }
            }
        }
    }

    private var emptyPrompt: some View {
        VStack(spacing: 16) {
            EmptyStateView(
                icon: "sparkles",
                title: "Welcome!",
                message: "Create your first exercise to unlock stats, goals and activity widgets.",
                buttonTitle: "Add Exercise",
                buttonAction: { showingAddExercise = true }
            )
            .frame(height: 320)
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
}
