import SwiftUI

struct PeriodFilterPicker: View {
    @Binding var selection: HistoryPeriodFilter

    var body: some View {
        HStack(spacing: 0) {
            ForEach(HistoryPeriodFilter.allCases) { filter in
                Button {
                    selection = filter
                } label: {
                    Text(filter.title)
                        .font(.caption.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            selection == filter
                                ? AnyShapeStyle(AppTheme.accentGradient())
                                : AnyShapeStyle(Color.clear)
                        )
                        .foregroundStyle(selection == filter ? Color.white : AppTheme.textPrimary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .appFlatCard(accent: AppTheme.accent)
    }
}
