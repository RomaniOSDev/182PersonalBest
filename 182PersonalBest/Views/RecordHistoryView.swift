import SwiftUI

struct RecordHistoryView: View {
    @StateObject private var viewModel: RecordHistoryViewModel
    @ObservedObject private var storage = ExerciseStorageService.shared

    init(exerciseId: UUID) {
        _viewModel = StateObject(wrappedValue: RecordHistoryViewModel(exerciseId: exerciseId))
    }

    private var exercise: Exercise? {
        storage.exercise(with: viewModel.exerciseId)
    }

    var body: some View {
        Group {
            if let exercise {
                content(for: exercise)
            } else {
                EmptyStateView(
                    icon: "exclamationmark.triangle",
                    title: "Not found",
                    message: "This exercise may have been deleted."
                )
            }
        }
        .screenBackground()
        .navigationTitle(exercise?.name ?? "History")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.showingAddForm) {
            RecordFormView(
                exerciseId: viewModel.exerciseId,
                record: viewModel.recordToEdit
            )
        }
    }

    @ViewBuilder
    private func content(for exercise: Exercise) -> some View {
        List {
            Section {
                RecordHeroView(exercise: exercise)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)

                if exercise.targetValue != nil {
                    GoalProgressView(exercise: exercise)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }

                if let improvement = viewModel.improvement {
                    ImprovementCellView(improvement: improvement, category: exercise.category)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }

                AppPrimaryButton("Add New Record", icon: "plus") {
                    viewModel.showAddForm()
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

                ProgressChartView(
                    records: viewModel.chartRecords,
                    unit: exercise.unit,
                    accent: exercise.category.themeColor
                )
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }

            Section {
                PeriodFilterPicker(selection: $viewModel.periodFilter)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowBackground(Color.clear)
            }

            Section {
                if viewModel.filteredRecords.isEmpty {
                    Text("No records in this period.")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 24)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(Array(viewModel.filteredRecords.enumerated()), id: \.element.id) { index, record in
                        RecordCellView(
                            record: record,
                            unit: exercise.unit,
                            isBest: viewModel.isBestRecord(record),
                            categoryColor: exercise.category.themeColor,
                            isLast: index == viewModel.filteredRecords.count - 1
                        )
                        .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 2, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .contextMenu {
                            Button("Edit", systemImage: "pencil") {
                                viewModel.showEditForm(for: record)
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.deleteRecord(record)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            } header: {
                SectionHeaderView(title: "All Records", subtitle: "\(viewModel.filteredRecords.count) shown")
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

#Preview {
    NavigationStack {
        RecordHistoryView(exerciseId: UUID())
    }
}
