import SwiftUI

struct ExerciseListView: View {
    @StateObject private var viewModel = ExerciseListViewModel()
    @ObservedObject private var storage = ExerciseStorageService.shared
    @State private var navigationPath = NavigationPath()

    private var totalRecords: Int {
        storage.exercises.reduce(0) { $0 + $1.records.count }
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: 16) {
                    if !storage.exercises.isEmpty {
                        summaryHeader
                        CategoryFilterBar(selectedCategory: $viewModel.selectedCategory)
                    }

                    if storage.exercises.isEmpty {
                        EmptyStateView(
                            icon: "figure.strengthtraining.traditional",
                            title: "No exercises yet",
                            message: "Track your personal bests across strength, cardio and flexibility.",
                            buttonTitle: "Add Exercise",
                            buttonAction: { viewModel.showAddForm() }
                        )
                        .padding(.top, 40)
                    } else if viewModel.filteredExercises.isEmpty {
                        EmptyStateView(
                            icon: "magnifyingglass",
                            title: "No matching exercises",
                            message: "Try another search term or reset the category filter."
                        )
                        .padding(.top, 60)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredExercises) { exercise in
                                ExerciseCellView(exercise: exercise)
                                    .contentShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
                                    .onTapGesture {
                                        navigationPath.append(exercise.id)
                                    }
                                    .contextMenu {
                                        Button("Edit", systemImage: "pencil") {
                                            viewModel.showEditForm(for: exercise)
                                        }
                                        Button(exercise.isPinned ? "Unpin" : "Pin", systemImage: exercise.isPinned ? "pin.slash" : "pin") {
                                            viewModel.togglePin(exercise)
                                        }
                                        Button("Delete", systemImage: "trash", role: .destructive) {
                                            viewModel.deleteExercise(exercise)
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                }
            }
            .screenBackground()
            .navigationTitle("Exercises")
            .searchable(text: $viewModel.searchText, prompt: "Search exercises")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker("Sort", selection: $viewModel.sortOption) {
                            ForEach(ExerciseSortOption.allCases) { option in
                                Text(option.title).tag(option)
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.arrow.down")
                            Text(viewModel.sortOption.title)
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundStyle(AppTheme.accent)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showAddForm()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(AppTheme.accent)
                    }
                }
            }
            .navigationDestination(for: UUID.self) { exerciseId in
                RecordHistoryView(exerciseId: exerciseId)
            }
            .sheet(isPresented: $viewModel.showingAddForm) {
                ExerciseFormView(exercise: viewModel.exerciseToEdit)
            }
        }
    }

    private var summaryHeader: some View {
        HStack(spacing: 12) {
            summaryPill(value: "\(storage.exercises.count)", label: "Exercises", icon: "list.bullet")
            summaryPill(value: "\(totalRecords)", label: "Records", icon: "trophy")
            summaryPill(value: "\(storage.exercises.filter(\.isPinned).count)", label: "Pinned", icon: "pin.fill")
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private func summaryPill(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(value)
                    .font(.headline.weight(.bold))
            }
            .foregroundStyle(AppTheme.accent)

            Text(label)
                .font(.caption2)
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .appFlatCard(accent: AppTheme.accent)
    }
}

#Preview {
    ExerciseListView()
}
