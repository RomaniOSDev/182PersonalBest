import Combine
import Foundation

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0

    let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            title: "Track Your Records",
            subtitle: "Log personal bests for strength, cardio and flexibility — all in one place.",
            icon: "trophy.fill",
            accent: "blue",
            imageName: "HomeHeroBanner"
        ),
        OnboardingPage(
            id: 1,
            title: "Watch Your Progress",
            subtitle: "Set goals, view charts and insights to see how far you've come.",
            icon: "chart.line.uptrend.xyaxis",
            accent: "green",
            imageName: nil
        ),
        OnboardingPage(
            id: 2,
            title: "Stay Consistent",
            subtitle: "Log full workouts, get reminders and back up your data anytime.",
            icon: "bell.badge.fill",
            accent: "coral",
            imageName: "HomeCategoryStrip"
        )
    ]

    var isLastPage: Bool {
        currentPage == pages.count - 1
    }

    var primaryButtonTitle: String {
        isLastPage ? "Get Started" : "Next"
    }

    func nextPage() {
        guard !isLastPage else { return }
        currentPage += 1
    }

    func complete() {
        OnboardingService.markCompleted()
    }
}
