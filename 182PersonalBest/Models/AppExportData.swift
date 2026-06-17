import Foundation

struct AppExportData: Codable {
    var exercises: [Exercise]
    var workoutSessions: [WorkoutSession]
    var exportedAt: Date
}
