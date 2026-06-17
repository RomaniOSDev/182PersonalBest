import Foundation

enum ExerciseSortOption: String, CaseIterable, Identifiable {
    case dateAdded
    case recordValue
    case alphabetically

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dateAdded: return "Date Added"
        case .recordValue: return "Record Value"
        case .alphabetically: return "Alphabetically"
        }
    }
}
