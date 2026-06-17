import Combine
import Foundation

struct HomeStatItem: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let accent: String
}

struct HomeRecentActivityItem: Identifiable {
    let id: UUID
    let exerciseId: UUID
    let exerciseName: String
    let unit: String
    let value: Double
    let date: Date
    let category: ExerciseCategory
    let isBest: Bool
}

struct HomeGoalItem: Identifiable {
    let id: UUID
    let exercise: Exercise
    let progress: Double
}

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var stats: [HomeStatItem] = []
    @Published private(set) var pinnedExercises: [Exercise] = []
    @Published private(set) var goalItems: [HomeGoalItem] = []
    @Published private(set) var recentActivity: [HomeRecentActivityItem] = []
    @Published private(set) var highlightText: String = "Start tracking your personal bests today."
    @Published private(set) var recordsThisMonth: Int = 0

    private let storage: ExerciseStorageService

    init(storage: ExerciseStorageService? = nil) {
        self.storage = storage ?? ExerciseStorageService.shared
        refresh()
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }

    var hasData: Bool {
        !storage.exercises.isEmpty
    }

    func refresh() {
        let exercises = storage.exercises
        let summary = StatisticsService.makeSummary(from: exercises)
        recordsThisMonth = summary.recordsThisMonth

        let totalRecords = exercises.reduce(0) { $0 + $1.records.count }
        let goalsReached = exercises.filter(\.isGoalReached).count
        let goalsTotal = exercises.filter { $0.targetValue != nil }.count

        stats = [
            HomeStatItem(
                title: "Exercises",
                value: "\(exercises.count)",
                subtitle: "In your library",
                icon: "dumbbell.fill",
                accent: "blue"
            ),
            HomeStatItem(
                title: "Records",
                value: "\(totalRecords)",
                subtitle: "All time",
                icon: "trophy.fill",
                accent: "coral"
            ),
            HomeStatItem(
                title: "This Month",
                value: "\(summary.recordsThisMonth)",
                subtitle: "New records",
                icon: "calendar",
                accent: "green"
            ),
            HomeStatItem(
                title: "Goals",
                value: goalsTotal == 0 ? "—" : "\(goalsReached)/\(goalsTotal)",
                subtitle: "Completed",
                icon: "target",
                accent: "navy"
            )
        ]

        pinnedExercises = exercises
            .filter(\.isPinned)
            .prefix(4)
            .map { $0 }

        goalItems = exercises
            .compactMap { exercise -> HomeGoalItem? in
                guard let progress = exercise.goalProgress, !exercise.isGoalReached else { return nil }
                return HomeGoalItem(id: exercise.id, exercise: exercise, progress: progress)
            }
            .sorted { $0.progress > $1.progress }
            .prefix(5)
            .map { $0 }

        recentActivity = exercises
            .flatMap { exercise in
                exercise.records.map { record in
                    HomeRecentActivityItem(
                        id: record.id,
                        exerciseId: exercise.id,
                        exerciseName: exercise.name,
                        unit: exercise.unit,
                        value: record.value,
                        date: record.date,
                        category: exercise.category,
                        isBest: exercise.bestRecord?.id == record.id
                    )
                }
            }
            .sorted { $0.date > $1.date }
            .prefix(6)
            .map { $0 }

        if let top = summary.improvements.first {
            highlightText = "\(top.exerciseName): \(top.deltaText) \(top.periodText)"
        } else if recordsThisMonth > 0 {
            highlightText = "You logged \(recordsThisMonth) records this month. Keep going!"
        } else if exercises.isEmpty {
            highlightText = "Add your first exercise and start beating your personal bests."
        } else {
            highlightText = "Log today's workout and track your progress."
        }
    }
}
