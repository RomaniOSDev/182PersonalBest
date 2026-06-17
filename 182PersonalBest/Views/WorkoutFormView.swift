import SwiftUI

struct WorkoutFormView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = WorkoutFormViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    FormSectionCard(title: "Session", subtitle: "When did you train?") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Workout Date")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppTheme.textSecondary)
                                .textCase(.uppercase)
                            DatePicker("", selection: $viewModel.date, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .tint(AppTheme.accent)
                        }
                    }

                    FormSectionCard(title: "Note", subtitle: "Optional session description") {
                        TextEditor(text: $viewModel.note)
                            .frame(minHeight: 80)
                            .scrollContentBackground(.hidden)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall, style: .continuous)
                                    .fill(AppTheme.fieldBackground)
                            )
                    }

                    FormSectionCard(title: "Exercises", subtitle: "Add records for this session") {
                        if viewModel.availableExercises.isEmpty {
                            Text("No exercises available")
                                .foregroundStyle(AppTheme.textSecondary)
                        } else {
                            Menu {
                                ForEach(viewModel.availableExercises) { exercise in
                                    Button {
                                        viewModel.addEntry(for: exercise)
                                    } label: {
                                        Label(exercise.name, systemImage: exercise.category.iconName)
                                    }
                                    .disabled(viewModel.entries.contains { $0.exerciseId == exercise.id })
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Exercise")
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                                .font(.headline)
                                .foregroundStyle(AppTheme.accent)
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall, style: .continuous)
                                        .fill(AppTheme.accent.opacity(0.1))
                                )
                            }
                        }
                    }

                    if !viewModel.entries.isEmpty {
                        FormSectionCard(title: "Records", subtitle: "\(viewModel.entries.count) exercises added") {
                            VStack(spacing: 12) {
                                ForEach(Array(viewModel.entries.enumerated()), id: \.element.id) { index, entry in
                                    if let exercise = viewModel.availableExercises.first(where: { $0.id == entry.exerciseId }) {
                                        WorkoutEntryCell(
                                            exercise: exercise,
                                            valueText: Binding(
                                                get: { viewModel.entries[index].valueText },
                                                set: { viewModel.entries[index].valueText = $0 }
                                            ),
                                            note: Binding(
                                                get: { viewModel.entries[index].note },
                                                set: { viewModel.entries[index].note = $0 }
                                            ),
                                            onRemove: { viewModel.removeEntry(entry) }
                                        )
                                    }
                                }
                            }
                        }
                    }

                    if viewModel.showValidationError && !viewModel.isValid {
                        Label("Add at least one exercise with a valid value", systemImage: "exclamationmark.circle")
                            .font(.caption)
                            .foregroundStyle(AppTheme.accent)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    VStack(spacing: 12) {
                        AppPrimaryButton("Save Workout", icon: "checkmark") {
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
            .navigationTitle("New Workout")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.large])
    }
}

#Preview {
    WorkoutFormView()
}
