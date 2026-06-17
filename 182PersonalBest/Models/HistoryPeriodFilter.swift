import Foundation

enum HistoryPeriodFilter: String, CaseIterable, Identifiable {
    case all
    case week
    case month
    case year

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All"
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        }
    }

    func filter(_ records: [Record], referenceDate: Date = Date()) -> [Record] {
        switch self {
        case .all:
            return records
        case .week:
            guard let start = Calendar.current.date(byAdding: .day, value: -7, to: referenceDate) else { return records }
            return records.filter { $0.date >= start }
        case .month:
            guard let start = Calendar.current.date(byAdding: .month, value: -1, to: referenceDate) else { return records }
            return records.filter { $0.date >= start }
        case .year:
            guard let start = Calendar.current.date(byAdding: .year, value: -1, to: referenceDate) else { return records }
            return records.filter { $0.date >= start }
        }
    }
}
