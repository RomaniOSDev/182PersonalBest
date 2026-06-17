import Foundation

struct Exercise: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var unit: String
    var category: ExerciseCategory
    var recordType: RecordComparisonType
    var targetValue: Double?
    var isPinned: Bool
    var goalNotified: Bool
    var currentRecordValue: Double
    var currentRecordDate: Date
    var records: [Record]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        unit: String,
        category: ExerciseCategory = .strength,
        recordType: RecordComparisonType = .higherIsBetter,
        targetValue: Double? = nil,
        isPinned: Bool = false,
        goalNotified: Bool = false,
        currentRecordValue: Double = 0,
        currentRecordDate: Date = Date(),
        records: [Record] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.unit = unit
        self.category = category
        self.recordType = recordType
        self.targetValue = targetValue
        self.isPinned = isPinned
        self.goalNotified = goalNotified
        self.currentRecordValue = currentRecordValue
        self.currentRecordDate = currentRecordDate
        self.records = records
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        unit = try container.decode(String.self, forKey: .unit)
        category = try container.decodeIfPresent(ExerciseCategory.self, forKey: .category) ?? .strength
        recordType = try container.decodeIfPresent(RecordComparisonType.self, forKey: .recordType) ?? .higherIsBetter
        targetValue = try container.decodeIfPresent(Double.self, forKey: .targetValue)
        isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        goalNotified = try container.decodeIfPresent(Bool.self, forKey: .goalNotified) ?? false
        currentRecordValue = try container.decode(Double.self, forKey: .currentRecordValue)
        currentRecordDate = try container.decode(Date.self, forKey: .currentRecordDate)
        records = try container.decode([Record].self, forKey: .records)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }

    var bestRecord: Record? {
        switch recordType {
        case .higherIsBetter:
            return records.max(by: { $0.value < $1.value })
        case .lowerIsBetter:
            return records.min(by: { $0.value < $1.value })
        }
    }

    var hasRecords: Bool {
        !records.isEmpty
    }

    var goalProgress: Double? {
        guard let target = targetValue, target > 0, hasRecords else { return nil }
        switch recordType {
        case .higherIsBetter:
            return min(currentRecordValue / target, 1.0)
        case .lowerIsBetter:
            if currentRecordValue <= target { return 1.0 }
            return min(target / currentRecordValue, 1.0)
        }
    }

    var isGoalReached: Bool {
        guard let target = targetValue, hasRecords else { return false }
        switch recordType {
        case .higherIsBetter:
            return currentRecordValue >= target
        case .lowerIsBetter:
            return currentRecordValue <= target
        }
    }

    func isBetter(than current: Double, value: Double) -> Bool {
        switch recordType {
        case .higherIsBetter:
            return value > current
        case .lowerIsBetter:
            return current == 0 || value < current
        }
    }

    mutating func recalculateCurrentRecord() {
        if let best = bestRecord {
            currentRecordValue = best.value
            currentRecordDate = best.date
        } else {
            currentRecordValue = 0
            currentRecordDate = createdAt
        }

        if !isGoalReached {
            goalNotified = false
        }
    }

    mutating func updateGoalNotificationState() {
        if isGoalReached {
            // goalNotified is set by storage when notification is sent
        } else {
            goalNotified = false
        }
    }
}
