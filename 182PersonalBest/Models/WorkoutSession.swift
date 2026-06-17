import Foundation

struct WorkoutEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var exerciseId: UUID
    var value: Double
    var note: String?

    init(id: UUID = UUID(), exerciseId: UUID, value: Double, note: String? = nil) {
        self.id = id
        self.exerciseId = exerciseId
        self.value = value
        self.note = note
    }
}

struct WorkoutSession: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    var note: String?
    var entries: [WorkoutEntry]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        date: Date,
        note: String? = nil,
        entries: [WorkoutEntry] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.note = note
        self.entries = entries
        self.createdAt = createdAt
    }
}
