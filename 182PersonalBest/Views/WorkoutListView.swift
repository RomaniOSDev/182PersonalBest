import SwiftUI

struct WorkoutListView: View {
    @StateObject private var viewModel = WorkoutListViewModel()
    @ObservedObject private var storage = ExerciseStorageService.shared
    @State private var showingAddForm = false

    var body: some View {
        NavigationStack {
            Group {
                if storage.exercises.isEmpty {
                    EmptyStateView(
                        icon: "figure.strengthtraining.traditional",
                        title: "Create exercises first",
                        message: "You need at least one exercise before logging a workout session."
                    )
                } else if viewModel.sessions.isEmpty {
                    EmptyStateView(
                        icon: "calendar.badge.plus",
                        title: "No workouts yet",
                        message: "Log multiple records in a single session — faster than one by one.",
                        buttonTitle: "Log Workout",
                        buttonAction: { showingAddForm = true }
                    )
                } else {
                    sessionList
                }
            }
            .screenBackground()
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddForm = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(AppTheme.accent)
                    }
                }
            }
            .sheet(isPresented: $showingAddForm) {
                WorkoutFormView()
            }
        }
    }

    private var sessionList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.sessions) { session in
                    WorkoutSessionCellView(
                        session: session,
                        exerciseName: viewModel.exerciseName(for:),
                        exerciseUnit: viewModel.exerciseUnit(for:),
                        exerciseCategory: { id in
                            storage.exercise(with: id)?.category ?? .strength
                        }
                    )
                    .contextMenu {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            viewModel.deleteSession(session)
                        }
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    WorkoutListView()
}
