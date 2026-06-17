import Foundation

struct ReminderSettings: Codable, Equatable {
    var isEnabled: Bool
    var hour: Int
    var minute: Int
    var weekdays: [Int]

    static let `default` = ReminderSettings(
        isEnabled: false,
        hour: 18,
        minute: 0,
        weekdays: [2, 3, 4, 5, 6]
    )

    var weekdaySet: Set<Int> {
        get { Set(weekdays) }
        set { weekdays = newValue.sorted() }
    }
}
