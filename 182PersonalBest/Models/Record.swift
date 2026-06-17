import Foundation

struct Record: Identifiable, Codable, Equatable {
    let id: UUID
    var value: Double
    var date: Date
    var note: String?

    init(id: UUID = UUID(), value: Double, date: Date, note: String? = nil) {
        self.id = id
        self.value = value
        self.date = date
        self.note = note
    }
}
