import Combine
import Foundation

struct WorkoutEntryDraft: Identifiable, Equatable {
    let id: UUID
    var exerciseId: UUID
    var valueText: String
    var note: String

    init(id: UUID = UUID(), exerciseId: UUID, valueText: String = "", note: String = "") {
        self.id = id
        self.exerciseId = exerciseId
        self.valueText = valueText
        self.note = note
    }
}

@MainActor
final class WorkoutFormViewModel: ObservableObject {
    @Published var date: Date
    @Published var note: String
    @Published var entries: [WorkoutEntryDraft]
    @Published var showValidationError = false

    private let storage: ExerciseStorageService

    init(storage: ExerciseStorageService? = nil) {
        self.storage = storage ?? ExerciseStorageService.shared
        self.date = Date()
        self.note = ""
        self.entries = []
    }

    var availableExercises: [Exercise] {
        storage.exercises.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var isValid: Bool {
        !entries.isEmpty && entries.allSatisfy { draft in
            guard let value = Double(draft.valueText.replacingOccurrences(of: ",", with: ".")) else { return false }
            return value > 0
        }
    }

    func addEntry(for exercise: Exercise) {
        guard !entries.contains(where: { $0.exerciseId == exercise.id }) else { return }
        entries.append(WorkoutEntryDraft(exerciseId: exercise.id))
    }

    func removeEntry(_ draft: WorkoutEntryDraft) {
        entries.removeAll { $0.id == draft.id }
    }

    func save() -> Bool {
        guard isValid else {
            showValidationError = true
            return false
        }

        let workoutEntries: [WorkoutEntry] = entries.compactMap { draft in
            guard let value = Double(draft.valueText.replacingOccurrences(of: ",", with: ".")) else { return nil }
            let trimmedNote = draft.note.trimmingCharacters(in: .whitespacesAndNewlines)
            return WorkoutEntry(
                exerciseId: draft.exerciseId,
                value: value,
                note: trimmedNote.isEmpty ? nil : trimmedNote
            )
        }

        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        storage.addWorkoutSession(
            date: date,
            note: trimmedNote.isEmpty ? nil : trimmedNote,
            entries: workoutEntries
        )
        return true
    }
}

@MainActor
final class WorkoutListViewModel: ObservableObject {
    @Published var showingAddForm = false

    private let storage: ExerciseStorageService

    init(storage: ExerciseStorageService? = nil) {
        self.storage = storage ?? ExerciseStorageService.shared
    }

    var sessions: [WorkoutSession] {
        storage.workoutSessions
    }

    func deleteSession(_ session: WorkoutSession) {
        storage.deleteWorkoutSession(id: session.id)
    }

    func exerciseName(for id: UUID) -> String {
        storage.exercise(with: id)?.name ?? "Unknown"
    }

    func exerciseUnit(for id: UUID) -> String {
        storage.exercise(with: id)?.unit ?? ""
    }
}
