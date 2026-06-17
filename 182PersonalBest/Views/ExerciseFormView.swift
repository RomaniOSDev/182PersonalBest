import SwiftUI

struct ExerciseFormView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ExerciseFormViewModel

    init(exercise: Exercise? = nil) {
        _viewModel = StateObject(wrappedValue: ExerciseFormViewModel(exercise: exercise))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    FormSectionCard(title: "Details", subtitle: "Name and measurement unit") {
                        VStack(spacing: 14) {
                            AppFormField(title: "Name", placeholder: "e.g. Bench Press", text: $viewModel.name)
                            AppFormField(title: "Unit", placeholder: "kg, sec, min, reps, km", text: $viewModel.unit)
                        }
                    }

                    FormSectionCard(title: "Category", subtitle: "Choose exercise type") {
                        CategorySelectionGrid(selection: $viewModel.category)
                    }

                    FormSectionCard(title: "Record Type", subtitle: "How progress is measured") {
                        RecordTypeSelector(selection: $viewModel.recordType)
                    }

                    FormSectionCard(title: "Goal", subtitle: "Optional target with progress tracking") {
                        AppFormField(
                            title: "Target Value",
                            placeholder: "e.g. 100",
                            text: $viewModel.targetValueText,
                            keyboardType: .decimalPad
                        )
                    }

                    if viewModel.showValidationError && !viewModel.isValid {
                        Label("Fill in required fields with valid values", systemImage: "exclamationmark.circle")
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
                    .padding(.top, 4)
                }
                .padding(16)
                .padding(.bottom, 24)
            }
            .screenBackground()
            .navigationTitle(viewModel.isEditing ? "Edit Exercise" : "New Exercise")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.large])
    }
}

#Preview {
    ExerciseFormView()
}
