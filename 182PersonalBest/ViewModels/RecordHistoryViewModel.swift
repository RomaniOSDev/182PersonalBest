import Combine
import Foundation

@MainActor
final class RecordHistoryViewModel: ObservableObject {
    @Published var showingAddForm = false
    @Published var recordToEdit: Record?
    @Published var periodFilter: HistoryPeriodFilter = .all

    let exerciseId: UUID
    private let storage: ExerciseStorageService

    init(exerciseId: UUID, storage: ExerciseStorageService? = nil) {
        self.exerciseId = exerciseId
        self.storage = storage ?? ExerciseStorageService.shared
    }

    var exercise: Exercise? {
        storage.exercise(with: exerciseId)
    }

    var filteredRecords: [Record] {
        guard let exercise else { return [] }
        return periodFilter
            .filter(exercise.records)
            .sorted { $0.date > $1.date }
    }

    var chartRecords: [Record] {
        guard let exercise else { return [] }
        return periodFilter
            .filter(exercise.records)
            .sorted { $0.date < $1.date }
    }

    var improvement: ExerciseImprovement? {
        guard let exercise else { return nil }
        return StatisticsService.improvement(for: exercise)
    }

    func isBestRecord(_ record: Record) -> Bool {
        guard let best = exercise?.bestRecord else { return false }
        return record.id == best.id
    }

    func deleteRecord(_ record: Record) {
        storage.deleteRecord(exerciseId: exerciseId, recordId: record.id)
    }

    func showAddForm() {
        recordToEdit = nil
        showingAddForm = true
    }

    func showEditForm(for record: Record) {
        recordToEdit = record
        showingAddForm = true
    }
}
