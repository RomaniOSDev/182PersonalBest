import Foundation
import UserNotifications

@MainActor
final class NotificationService {
    static let shared = NotificationService()

    private let reminderIdentifierPrefix = "workout_reminder_"
    private let center = UNUserNotificationCenter.current()

    private init() {}

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    func updateReminders(settings: ReminderSettings) async {
        await cancelReminders()

        guard settings.isEnabled else { return }

        let granted = await requestAuthorization()
        guard granted else { return }

        for weekday in settings.weekdays {
            var components = DateComponents()
            components.weekday = weekday
            components.hour = settings.hour
            components.minute = settings.minute

            let content = UNMutableNotificationContent()
            content.title = "Log Your Progress"
            content.body = "Record your results after today's workout."
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(
                identifier: "\(reminderIdentifierPrefix)\(weekday)",
                content: content,
                trigger: trigger
            )

            try? await center.add(request)
        }
    }

    func cancelReminders() async {
        let identifiers = (1...7).map { "\(reminderIdentifierPrefix)\($0)" }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func notifyGoalReached(exerciseName: String, value: Double, unit: String) {
        let content = UNMutableNotificationContent()
        content.title = "Goal Reached!"
        content.body = "You hit your target for \(exerciseName): \(AppTheme.formattedValue(value)) \(unit)."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "goal_\(exerciseName)_\(UUID().uuidString)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )

        center.add(request)
    }
}
