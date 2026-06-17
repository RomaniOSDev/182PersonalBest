import Combine
import Foundation

@MainActor
final class ExerciseFormViewModel: ObservableObject {
    @Published var name: String
    @Published var unit: String
    @Published var category: ExerciseCategory
    @Published var recordType: RecordComparisonType
    @Published var targetValueText: String
    @Published var showValidationError = false

    let isEditing: Bool
    private let exerciseId: UUID?
    private let storage: ExerciseStorageService

    init(exercise: Exercise? = nil, storage: ExerciseStorageService? = nil) {
        self.storage = storage ?? ExerciseStorageService.shared
        self.isEditing = exercise != nil
        self.exerciseId = exercise?.id
        self.name = exercise?.name ?? ""
        self.unit = exercise?.unit ?? ""
        self.category = exercise?.category ?? .strength
        self.recordType = exercise?.recordType ?? .higherIsBetter
        self.targetValueText = exercise?.targetValue.map { AppTheme.formattedValue($0) } ?? ""
    }

    var parsedTargetValue: Double? {
        let trimmed = targetValueText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return Double(trimmed.replacingOccurrences(of: ",", with: "."))
    }

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !unit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && (targetValueText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || parsedTargetValue != nil)
    }

    func save() -> Bool {
        guard isValid else {
            showValidationError = true
            return false
        }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedUnit = unit.trimmingCharacters(in: .whitespacesAndNewlines)

        if let exerciseId, var exercise = storage.exercise(with: exerciseId) {
            exercise.name = trimmedName
            exercise.unit = trimmedUnit
            exercise.category = category
            exercise.recordType = recordType
            exercise.targetValue = parsedTargetValue
            exercise.updateGoalNotificationState()
            storage.updateExercise(exercise)
        } else {
            storage.addExercise(
                name: trimmedName,
                unit: trimmedUnit,
                category: category,
                recordType: recordType,
                targetValue: parsedTargetValue
            )
        }

        return true
    }
}
