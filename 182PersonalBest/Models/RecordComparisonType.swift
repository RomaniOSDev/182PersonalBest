import Foundation

enum RecordComparisonType: String, Codable, CaseIterable, Identifiable {
    case higherIsBetter
    case lowerIsBetter

    var id: String { rawValue }

    var title: String {
        switch self {
        case .higherIsBetter: return "Higher is Better"
        case .lowerIsBetter: return "Lower is Better"
        }
    }
}
