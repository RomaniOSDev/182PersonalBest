import SwiftUI

struct RecordFormView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: RecordFormViewModel
    @ObservedObject private var storage = ExerciseStorageService.shared

    init(exerciseId: UUID, record: Record? = nil) {
        _viewModel = StateObject(wrappedValue: RecordFormViewModel(exerciseId: exerciseId, record: record))
    }

    private var exercise: Exercise? {
        storage.exercise(with: viewModel.exerciseId)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let exercise {
                        HStack(spacing: 12) {
                            CategoryIconBadge(category: exercise.category, size: 40)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(exercise.name)
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.textPrimary)
                                Text("Unit: \(exercise.unit)")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(16)
                        .appCard(accent: exercise.category.themeColor, elevation: .soft)
                    }

                    FormSectionCard(title: "Record", subtitle: "Value and date of achievement") {
                        VStack(spacing: 14) {
                            AppFormField(
                                title: "Value",
                                placeholder: "Enter record value",
                                text: $viewModel.valueText,
                                keyboardType: .decimalPad
                            )

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Date")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .textCase(.uppercase)
                                DatePicker("", selection: $viewModel.date, displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .tint(AppTheme.accent)
                            }
                        }
                    }

                    FormSectionCard(title: "Note", subtitle: "Optional details about this record") {
                        TextEditor(text: $viewModel.note)
                            .frame(minHeight: 100)
                            .scrollContentBackground(.hidden)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall, style: .continuous)
                                    .fill(AppTheme.fieldBackground)
                            )
                            .foregroundStyle(AppTheme.textPrimary)
                    }

                    if viewModel.showValidationError && !viewModel.isValid {
                        Label("Enter a valid positive number", systemImage: "exclamationmark.circle")
                            .font(.caption)
                            .foregroundStyle(AppTheme.accent)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    VStack(spacing: 12) {
                        AppPrimaryButton("Save", icon: "checkmark") {
                            if viewModel.save() { dismiss() }
                        }
                        AppSecondaryButton(title: "Cancel") { dismiss() }
                    }
                }
                .padding(16)
                .padding(.bottom, 24)
            }
            .screenBackground()
            .navigationTitle(viewModel.isEditing ? "Edit Record" : "New Record")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.large])
    }
}

#Preview {
    RecordFormView(exerciseId: UUID())
}
