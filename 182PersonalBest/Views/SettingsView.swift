import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    private let weekdays: [(Int, String)] = [
        (1, "S"), (2, "M"), (3, "T"), (4, "W"),
        (5, "T"), (6, "F"), (7, "S")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    remindersSection
                    backupSection
                    legalSection
                }
                .padding(16)
                .padding(.bottom, 24)
            }
            .screenBackground()
            .navigationTitle("Settings")
            .onAppear {
                viewModel.syncFromStorage()
                Task { await viewModel.refreshAuthorizationStatus() }
            }
            .sheet(isPresented: $viewModel.showShareSheet) {
                if let url = viewModel.shareURL {
                    ShareSheetView(items: [url])
                }
            }
            .fileImporter(
                isPresented: $viewModel.showImportPicker,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        viewModel.importData(from: url)
                    }
                case .failure:
                    viewModel.alertMessage = "Failed to select file."
                    viewModel.showAlert = true
                }
            }
            .alert("Settings", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.alertMessage ?? "")
            }
        }
    }

    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Reminders", subtitle: "Never forget to log your results")

            SettingsToggleCell(
                title: "Workout Reminders",
                subtitle: "Daily notification to record progress",
                icon: "bell.fill",
                isOn: Binding(
                    get: { viewModel.reminderSettings.isEnabled },
                    set: { viewModel.toggleReminder($0) }
                )
            )

            if viewModel.reminderSettings.isEnabled {
                VStack(alignment: .leading, spacing: 14) {
                    DatePicker(
                        "Reminder Time",
                        selection: Binding(
                            get: {
                                Calendar.current.date(
                                    from: DateComponents(
                                        hour: viewModel.reminderSettings.hour,
                                        minute: viewModel.reminderSettings.minute
                                    )
                                ) ?? Date()
                            },
                            set: { newDate in
                                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                                viewModel.reminderSettings.hour = components.hour ?? 18
                                viewModel.reminderSettings.minute = components.minute ?? 0
                                viewModel.saveReminderSettings()
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall, style: .continuous)
                            .fill(AppTheme.cardBackground)
                    )

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Repeat on")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                            .textCase(.uppercase)

                        HStack(spacing: 6) {
                            ForEach(weekdays, id: \.0) { day, title in
                                let isSelected = viewModel.reminderSettings.weekdaySet.contains(day)
                                Button(title) {
                                    viewModel.toggleWeekday(day)
                                }
                                .font(.caption.weight(.bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    Circle()
                                        .fill(isSelected ? AnyShapeStyle(AppTheme.accentGradient()) : AnyShapeStyle(AppTheme.cardBackground))
                                )
                                .overlay {
                                    if !isSelected {
                                        Circle().strokeBorder(AppTheme.textPrimary.opacity(0.10), lineWidth: 1)
                                    }
                                }
                                .foregroundStyle(isSelected ? Color.white : AppTheme.textPrimary)
                            }
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall, style: .continuous)
                            .fill(AppTheme.cardBackground)
                    )

                    if !viewModel.notificationAuthorized {
                        Label("Enable notifications in iOS Settings", systemImage: "info.circle")
                            .font(.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }
        }
    }

    private var backupSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Backup & Export", subtitle: "Keep your data safe")

            VStack(spacing: 10) {
                SettingsActionCell(
                    title: "Export JSON",
                    subtitle: "Full backup with workouts",
                    icon: "doc.text",
                    iconColor: AppTheme.accent,
                    showChevron: false,
                    action: { viewModel.exportJSON() }
                )

                SettingsActionCell(
                    title: "Export CSV",
                    subtitle: "Spreadsheet-friendly format",
                    icon: "tablecells",
                    iconColor: AppTheme.accent,
                    showChevron: false,
                    action: { viewModel.exportCSV() }
                )

                SettingsActionCell(
                    title: "Import JSON Backup",
                    subtitle: "Restore from a previous export",
                    icon: "square.and.arrow.down",
                    iconColor: AppTheme.accent,
                    showChevron: false,
                    action: { viewModel.showImportPicker = true }
                )
            }
        }
    }

    private var legalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "About", subtitle: "Rate us and legal information")

            VStack(spacing: 10) {
                SettingsActionCell(
                    title: "Rate Us",
                    subtitle: "Enjoying the app? Leave a review",
                    icon: "star.fill",
                    iconColor: AppTheme.accent,
                    showChevron: false,
                    action: { viewModel.rateApp() }
                )

                SettingsActionCell(
                    title: "Privacy Policy",
                    subtitle: "How your data is handled",
                    icon: "hand.raised.fill",
                    iconColor: AppTheme.accent,
                    showChevron: false,
                    action: { viewModel.openLink(.privacyPolicy) }
                )

                SettingsActionCell(
                    title: "Terms of Use",
                    subtitle: "Rules for using the app",
                    icon: "doc.text.fill",
                    iconColor: AppTheme.accent,
                    showChevron: false,
                    action: { viewModel.openLink(.termsOfUse) }
                )
            }
        }
    }
}

struct ShareSheetView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView()
}
