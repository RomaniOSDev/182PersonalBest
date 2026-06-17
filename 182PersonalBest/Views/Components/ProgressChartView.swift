import SwiftUI
import Charts

struct ProgressChartView: View {
    let records: [Record]
    let unit: String
    var accent: Color = AppTheme.accent

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Progress", systemImage: "chart.xyaxis.line")
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                if records.count >= 2 {
                    Text("\(records.count) points")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }

            if records.count < 2 {
                VStack(spacing: 10) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.largeTitle)
                        .foregroundStyle(accent.opacity(0.4))
                    Text("Add at least 2 records to see the chart")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, minHeight: 140, alignment: .center)
            } else {
                Chart(records) { record in
                    AreaMark(
                        x: .value("Date", record.date),
                        y: .value("Value", record.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [accent.opacity(0.22), accent.opacity(0.02)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    LineMark(
                        x: .value("Date", record.date),
                        y: .value("Value", record.value)
                    )
                    .foregroundStyle(accent)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", record.date),
                        y: .value("Value", record.value)
                    )
                    .foregroundStyle(accent)
                    .symbolSize(36)
                }
                .chartYAxisLabel(unit)
                .frame(height: 190)
            }
        }
        .padding(16)
        .appCard(accent: accent, elevation: .soft)
    }
}
