import Combine
import Foundation

@MainActor
final class ExerciseStorageService: ObservableObject {
    static let shared = ExerciseStorageService()

    @Published private(set) var exercises: [Exercise] = []
    @Published var reminderSettings: ReminderSettings = .default

    private let exercisesKey = "personal_best_exercises"
    private let workoutsKey = "personal_best_workouts"
    private let remindersKey = "personal_best_reminders"
    private let userDefaults: UserDefaults
    private let notificationService: NotificationService

    @Published private(set) var workoutSessions: [WorkoutSession] = []

    init(
        userDefaults: UserDefaults = .standard,
        notificationService: NotificationService? = nil
    ) {
        self.userDefaults = userDefaults
        self.notificationService = notificationService ?? NotificationService.shared
        load()
    }

    func load() {
        if let data = userDefaults.data(forKey: exercisesKey),
           let decoded = try? JSONDecoder().decode([Exercise].self, from: data) {
            exercises = decoded
        } else {
            exercises = []
        }

        if let data = userDefaults.data(forKey: workoutsKey),
           let decoded = try? JSONDecoder().decode([WorkoutSession].self, from: data) {
            workoutSessions = decoded.sorted { $0.date > $1.date }
        } else {
            workoutSessions = []
        }

        if let data = userDefaults.data(forKey: remindersKey),
           let decoded = try? JSONDecoder().decode(ReminderSettings.self, from: data) {
            reminderSettings = decoded
        }
    }

    func saveExercises() {
        guard let data = try? JSONEncoder().encode(exercises) else { return }
        userDefaults.set(data, forKey: exercisesKey)
    }

    func saveWorkouts() {
        guard let data = try? JSONEncoder().encode(workoutSessions) else { return }
        userDefaults.set(data, forKey: workoutsKey)
    }

    func saveReminderSettings() {
        guard let data = try? JSONEncoder().encode(reminderSettings) else { return }
        userDefaults.set(data, forKey: remindersKey)
        Task {
            await notificationService.updateReminders(settings: reminderSettings)
        }
    }

    func exercise(with id: UUID) -> Exercise? {
        exercises.first { $0.id == id }
    }

    func filteredExercises(
        searchText: String,
        category: ExerciseCategory?,
        sortOption: ExerciseSortOption
    ) -> [Exercise] {
        var result = exercises

        if let category {
            result = result.filter { $0.category == category }
        }

        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSearch.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(trimmedSearch) }
        }

        result.sort { lhs, rhs in
            if lhs.isPinned != rhs.isPinned {
                return lhs.isPinned && !rhs.isPinned
            }

            switch sortOption {
            case .alphabetically:
                return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
            case .recordValue:
                if lhs.currentRecordValue == rhs.currentRecordValue {
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                }
                switch (lhs.recordType, rhs.recordType) {
                case (.lowerIsBetter, .lowerIsBetter):
                    if lhs.currentRecordValue == 0 { return false }
                    if rhs.currentRecordValue == 0 { return true }
                    return lhs.currentRecordValue < rhs.currentRecordValue
                default:
                    return lhs.currentRecordValue > rhs.currentRecordValue
                }
            case .dateAdded:
                return lhs.createdAt > rhs.createdAt
            }
        }

        return result
    }

    func addExercise(
        name: String,
        unit: String,
        category: ExerciseCategory,
        recordType: RecordComparisonType,
        targetValue: Double?
    ) {
        let exercise = Exercise(
            name: name,
            unit: unit,
            category: category,
            recordType: recordType,
            targetValue: targetValue
        )
        exercises.insert(exercise, at: 0)
        saveExercises()
    }

    func updateExercise(_ exercise: Exercise) {
        guard let index = exercises.firstIndex(where: { $0.id == exercise.id }) else { return }
        exercises[index] = exercise
        saveExercises()
    }

    func deleteExercise(id: UUID) {
        exercises.removeAll { $0.id == id }
        workoutSessions = workoutSessions.map { session in
            var updated = session
            updated.entries.removeAll { $0.exerciseId == id }
            return updated
        }.filter { !$0.entries.isEmpty }
        saveExercises()
        saveWorkouts()
    }

    func togglePin(exerciseId: UUID) {
        guard var exercise = exercise(with: exerciseId) else { return }
        exercise.isPinned.toggle()
        updateExercise(exercise)
    }

    func addRecord(to exerciseId: UUID, value: Double, date: Date, note: String?) {
        guard var exercise = exercise(with: exerciseId) else { return }

        let record = Record(value: value, date: date, note: note)
        exercise.records.append(record)
        exercise.records.sort { $0.date > $1.date }
        exercise.recalculateCurrentRecord()
        handleGoalReached(for: &exercise)
        updateExercise(exercise)
    }

    func updateRecord(exerciseId: UUID, record: Record) {
        guard var exercise = exercise(with: exerciseId) else { return }
        guard let index = exercise.records.firstIndex(where: { $0.id == record.id }) else { return }

        exercise.records[index] = record
        exercise.records.sort { $0.date > $1.date }
        exercise.recalculateCurrentRecord()
        handleGoalReached(for: &exercise)
        updateExercise(exercise)
    }

    func deleteRecord(exerciseId: UUID, recordId: UUID) {
        guard var exercise = exercise(with: exerciseId) else { return }
        exercise.records.removeAll { $0.id == recordId }
        exercise.recalculateCurrentRecord()
        updateExercise(exercise)
    }

    func addWorkoutSession(date: Date, note: String?, entries: [WorkoutEntry]) {
        let session = WorkoutSession(date: date, note: note, entries: entries)
        workoutSessions.insert(session, at: 0)

        for entry in entries {
            applyRecord(to: entry.exerciseId, value: entry.value, date: date, note: entry.note)
        }

        saveExercises()
        saveWorkouts()
    }

    func deleteWorkoutSession(id: UUID) {
        workoutSessions.removeAll { $0.id == id }
        saveWorkouts()
    }

    func replaceAllData(exercises: [Exercise], workoutSessions: [WorkoutSession]) {
        self.exercises = exercises
        self.workoutSessions = workoutSessions.sorted { $0.date > $1.date }
        saveExercises()
        saveWorkouts()
    }

    private func applyRecord(to exerciseId: UUID, value: Double, date: Date, note: String?) {
        guard var exercise = exercise(with: exerciseId) else { return }

        let record = Record(value: value, date: date, note: note)
        exercise.records.append(record)
        exercise.records.sort { $0.date > $1.date }
        exercise.recalculateCurrentRecord()
        handleGoalReached(for: &exercise)

        if let index = exercises.firstIndex(where: { $0.id == exerciseId }) {
            exercises[index] = exercise
        }
    }

    private func handleGoalReached(for exercise: inout Exercise) {
        guard exercise.isGoalReached, !exercise.goalNotified else { return }
        exercise.goalNotified = true
        notificationService.notifyGoalReached(
            exerciseName: exercise.name,
            value: exercise.currentRecordValue,
            unit: exercise.unit
        )
    }
}
