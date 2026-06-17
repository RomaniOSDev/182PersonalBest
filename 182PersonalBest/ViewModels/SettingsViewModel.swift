import Combine
import Foundation
import StoreKit
import UIKit
import UserNotifications

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var reminderSettings: ReminderSettings
    @Published var exportJSONURL: URL?
    @Published var exportCSVURL: URL?
    @Published var showShareSheet = false
    @Published var showImportPicker = false
    @Published var alertMessage: String?
    @Published var showAlert = false
    @Published var notificationAuthorized = false

    private let storage: ExerciseStorageService
    private let notificationService: NotificationService

    init(
        storage: ExerciseStorageService? = nil,
        notificationService: NotificationService? = nil
    ) {
        self.storage = storage ?? ExerciseStorageService.shared
        self.notificationService = notificationService ?? NotificationService.shared
        self.reminderSettings = self.storage.reminderSettings
    }

    func syncFromStorage() {
        reminderSettings = storage.reminderSettings
    }

    func refreshAuthorizationStatus() async {
        let status = await notificationService.authorizationStatus()
        notificationAuthorized = status == UNAuthorizationStatus.authorized
            || status == UNAuthorizationStatus.provisional
    }

    func saveReminderSettings() {
        storage.reminderSettings = reminderSettings
        storage.saveReminderSettings()
    }

    func toggleReminder(_ enabled: Bool) {
        reminderSettings.isEnabled = enabled
        saveReminderSettings()
    }

    func toggleWeekday(_ weekday: Int) {
        var set = reminderSettings.weekdaySet
        if set.contains(weekday) {
            set.remove(weekday)
        } else {
            set.insert(weekday)
        }
        reminderSettings.weekdaySet = set
        saveReminderSettings()
    }

    func exportJSON() {
        do {
            let data = try ExportImportService.exportJSON(from: storage)
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("personal_best_export.json")
            try data.write(to: url, options: .atomic)
            exportJSONURL = url
            exportCSVURL = nil
            showShareSheet = true
        } catch {
            presentAlert("Failed to export JSON.")
        }
    }

    func exportCSV() {
        let csv = ExportImportService.exportCSV(from: storage)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("personal_best_export.csv")
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            exportCSVURL = url
            exportJSONURL = nil
            showShareSheet = true
        } catch {
            presentAlert("Failed to export CSV.")
        }
    }

    func importData(from url: URL) {
        let accessed = url.startAccessingSecurityScopedResource()
        defer {
            if accessed { url.stopAccessingSecurityScopedResource() }
        }

        do {
            let data = try Data(contentsOf: url)
            let imported: AppExportData

            if url.pathExtension.lowercased() == "json" {
                imported = try ExportImportService.importJSON(data)
            } else {
                presentAlert("Please select a JSON backup file.")
                return
            }

            storage.replaceAllData(
                exercises: imported.exercises,
                workoutSessions: imported.workoutSessions
            )
            presentAlert("Import completed successfully.")
        } catch {
            presentAlert("Failed to import data.")
        }
    }

    var shareURL: URL? {
        exportJSONURL ?? exportCSVURL
    }

    func openLink(_ link: AppLinks) {
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }

    func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private func presentAlert(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}
