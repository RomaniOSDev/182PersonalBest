import Combine
import Foundation

@MainActor
final class InsightsViewModel: ObservableObject {
    @Published private(set) var summary: InsightSummary = InsightSummary(
        recordsThisMonth: 0,
        averageImprovementText: "—",
        bestMonth: nil,
        improvements: []
    )

    private let storage: ExerciseStorageService

    init(storage: ExerciseStorageService? = nil) {
        self.storage = storage ?? ExerciseStorageService.shared
        refresh()
    }

    func refresh() {
        summary = StatisticsService.makeSummary(from: storage.exercises)
    }
}
