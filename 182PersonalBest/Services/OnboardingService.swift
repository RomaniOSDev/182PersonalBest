import Foundation

enum OnboardingService {
    private static let completedKey = "has_completed_onboarding"

    static var hasCompleted: Bool {
        get { UserDefaults.standard.bool(forKey: completedKey) }
        set { UserDefaults.standard.set(newValue, forKey: completedKey) }
    }

    static func markCompleted() {
        hasCompleted = true
    }
}
