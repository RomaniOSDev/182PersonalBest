import Combine
import Foundation

@MainActor
final class RecordFormViewModel: ObservableObject {
    @Published var valueText: String
    @Published var date: Date
    @Published var note: String
    @Published var showValidationError = false

    let isEditing: Bool
    let exerciseId: UUID
    private let recordId: UUID?
    private let storage: ExerciseStorageService

    init(
        exerciseId: UUID,
        record: Record? = nil,
        storage: ExerciseStorageService? = nil
    ) {
        self.exerciseId = exerciseId
        self.storage = storage ?? ExerciseStorageService.shared
        self.isEditing = record != nil
        self.recordId = record?.id
        self.valueText = record.map { AppTheme.formattedValue($0.value) } ?? ""
        self.date = record?.date ?? Date()
        self.note = record?.note ?? ""
    }

    var parsedValue: Double? {
        Double(valueText.replacingOccurrences(of: ",", with: "."))
    }

    var isValid: Bool {
        guard let value = parsedValue else { return false }
        return value > 0
    }

    func save() -> Bool {
        guard isValid, let value = parsedValue else {
            showValidationError = true
            return false
        }

        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalNote = trimmedNote.isEmpty ? nil : trimmedNote

        if let recordId {
            let record = Record(id: recordId, value: value, date: date, note: finalNote)
            storage.updateRecord(exerciseId: exerciseId, record: record)
        } else {
            storage.addRecord(to: exerciseId, value: value, date: date, note: finalNote)
        }

        return true
    }
}
