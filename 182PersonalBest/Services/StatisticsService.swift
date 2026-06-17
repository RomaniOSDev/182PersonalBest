import Foundation

struct ExerciseImprovement: Identifiable {
    let id: UUID
    let exerciseName: String
    let unit: String
    let deltaText: String
    let periodText: String
}

struct MonthlyRecordCount: Identifiable {
    let id: String
    let monthTitle: String
    let count: Int
}

struct InsightSummary {
    let recordsThisMonth: Int
    let averageImprovementText: String
    let bestMonth: MonthlyRecordCount?
    let improvements: [ExerciseImprovement]
}

enum ExportImportService {
    static func makeExportData(from storage: ExerciseStorageService) -> AppExportData {
        AppExportData(
            exercises: storage.exercises,
            workoutSessions: storage.workoutSessions,
            exportedAt: Date()
        )
    }

    static func exportJSON(from storage: ExerciseStorageService) throws -> Data {
        let exportData = makeExportData(from: storage)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(exportData)
    }

    static func importJSON(_ data: Data) throws -> AppExportData {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(AppExportData.self, from: data)
    }

    static func exportCSV(from storage: ExerciseStorageService) -> String {
        var lines = ["Exercise,Unit,Category,Record Type,Target,Value,Date,Note,Workout Session"]

        for exercise in storage.exercises {
            let target = exercise.targetValue.map { AppTheme.formattedValue($0) } ?? ""
            let category = exercise.category.title
            let recordType = exercise.recordType.title

            if exercise.records.isEmpty {
                lines.append(csvRow([
                    exercise.name, exercise.unit, category, recordType, target,
                    "", "", "", ""
                ]))
            } else {
                for record in exercise.records.sorted(by: { $0.date > $1.date }) {
                    lines.append(csvRow([
                        exercise.name,
                        exercise.unit,
                        category,
                        recordType,
                        target,
                        AppTheme.formattedValue(record.value),
                        record.date.recordDisplayString,
                        record.note ?? "",
                        ""
                    ]))
                }
            }
        }

        for session in storage.workoutSessions {
            for entry in session.entries {
                let exercise = storage.exercise(with: entry.exerciseId)
                lines.append(csvRow([
                    exercise?.name ?? "Unknown",
                    exercise?.unit ?? "",
                    exercise?.category.title ?? "",
                    exercise?.recordType.title ?? "",
                    "",
                    AppTheme.formattedValue(entry.value),
                    session.date.recordDisplayString,
                    entry.note ?? session.note ?? "",
                    session.id.uuidString
                ]))
            }
        }

        return lines.joined(separator: "\n")
    }

    private static func csvRow(_ values: [String]) -> String {
        values.map { value in
            let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }.joined(separator: ",")
    }
}

enum StatisticsService {
    static func makeSummary(from exercises: [Exercise]) -> InsightSummary {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now

        let allRecords = exercises.flatMap(\.records)
        let recordsThisMonth = allRecords.filter { $0.date >= startOfMonth }.count

        let improvements = exercises.compactMap { improvement(for: $0) }
        let averageImprovementText = averageImprovementText(from: exercises)

        let bestMonth = bestMonth(from: allRecords)

        return InsightSummary(
            recordsThisMonth: recordsThisMonth,
            averageImprovementText: averageImprovementText,
            bestMonth: bestMonth,
            improvements: improvements
        )
    }

    static func improvement(for exercise: Exercise) -> ExerciseImprovement? {
        let sorted = exercise.records.sorted { $0.date < $1.date }
        guard let first = sorted.first, let last = sorted.last, sorted.count >= 2 else { return nil }

        let components = Calendar.current.dateComponents([.month, .day], from: first.date, to: last.date)
        let periodText = periodDescription(from: components)

        let deltaText: String
        switch exercise.recordType {
        case .higherIsBetter:
            let delta = last.value - first.value
            let sign = delta >= 0 ? "+" : ""
            deltaText = "\(sign)\(AppTheme.formattedValue(delta)) \(exercise.unit)"
        case .lowerIsBetter:
            let improvement = first.value - last.value
            let sign = improvement >= 0 ? "+" : ""
            deltaText = "\(sign)\(AppTheme.formattedValue(improvement)) \(exercise.unit)"
        }

        return ExerciseImprovement(
            id: exercise.id,
            exerciseName: exercise.name,
            unit: exercise.unit,
            deltaText: deltaText,
            periodText: periodText
        )
    }

    private static func averageImprovementText(from exercises: [Exercise]) -> String {
        let deltas: [Double] = exercises.compactMap { exercise in
            let sorted = exercise.records.sorted { $0.date < $1.date }
            guard let first = sorted.first, let last = sorted.last, sorted.count >= 2 else { return nil }
            switch exercise.recordType {
            case .higherIsBetter:
                return last.value - first.value
            case .lowerIsBetter:
                return first.value - last.value
            }
        }

        guard !deltas.isEmpty else { return "—" }
        let average = deltas.reduce(0, +) / Double(deltas.count)
        let sign = average >= 0 ? "+" : ""
        return "\(sign)\(AppTheme.formattedValue(average)) avg"
    }

    private static func bestMonth(from records: [Record]) -> MonthlyRecordCount? {
        guard !records.isEmpty else { return nil }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM yyyy"

        var counts: [String: (title: String, count: Int, sortDate: Date)] = [:]

        for record in records {
            let key = formatter.string(from: record.date)
            if var existing = counts[key] {
                existing.count += 1
                counts[key] = existing
            } else {
                let monthStart = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: record.date)) ?? record.date
                counts[key] = (key, 1, monthStart)
            }
        }

        guard let best = counts.values.max(by: { $0.count < $1.count }) else { return nil }
        return MonthlyRecordCount(id: best.title, monthTitle: best.title, count: best.count)
    }

    private static func periodDescription(from components: DateComponents) -> String {
        if let months = components.month, months > 0 {
            let suffix = months == 1 ? "month" : "months"
            return "over \(months) \(suffix)"
        }
        if let days = components.day, days > 0 {
            let suffix = days == 1 ? "day" : "days"
            return "over \(days) \(suffix)"
        }
        return "recently"
    }
}
