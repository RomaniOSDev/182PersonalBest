import Combine
import Foundation

@MainActor
final class ExerciseListViewModel: ObservableObject {
    @Published var showingAddForm = false
    @Published var exerciseToEdit: Exercise?
    @Published var searchText = ""
    @Published var selectedCategory: ExerciseCategory?
    @Published var sortOption: ExerciseSortOption = .dateAdded

    private let storage: ExerciseStorageService

    init(storage: ExerciseStorageService? = nil) {
        self.storage = storage ?? ExerciseStorageService.shared
    }

    var filteredExercises: [Exercise] {
        storage.filteredExercises(
            searchText: searchText,
            category: selectedCategory,
            sortOption: sortOption
        )
    }

    func deleteExercise(_ exercise: Exercise) {
        storage.deleteExercise(id: exercise.id)
    }

    func togglePin(_ exercise: Exercise) {
        storage.togglePin(exerciseId: exercise.id)
    }

    func showAddForm() {
        exerciseToEdit = nil
        showingAddForm = true
    }

    func showEditForm(for exercise: Exercise) {
        exerciseToEdit = exercise
        showingAddForm = true
    }
}
