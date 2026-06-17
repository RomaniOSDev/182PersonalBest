import SwiftUI

struct RecordCellView: View {
    let record: Record
    let unit: String
    let isBest: Bool
    let categoryColor: Color
    var isLast: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            timelineIndicator

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    Text(AppTheme.formattedValue(record.value))
                        .font(.title3.weight(.bold))
                        .foregroundStyle(isBest ? categoryColor : AppTheme.textPrimary)

                    Text(unit)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppTheme.textSecondary)

                    Spacer()

                    if isBest {
                        BestRecordBadge()
                    }
                }

                Label(record.date.recordDisplayString, systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)

                if let note = record.note, !note.isEmpty {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "text.quote")
                            .font(.caption)
                            .foregroundStyle(categoryColor.opacity(0.8))
                            .padding(.top, 2)
                        Text(note)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textPrimary.opacity(0.85))
                            .lineLimit(3)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(categoryColor.opacity(0.08))
                    )
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appFlatCard(accent: isBest ? categoryColor : categoryColor.opacity(0.5))
            .overlay {
                if isBest {
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall, style: .continuous)
                        .strokeBorder(categoryColor.opacity(0.45), lineWidth: 1.5)
                }
            }
        }
        .padding(.leading, 4)
    }

    private var timelineIndicator: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(isBest ? categoryColor : categoryColor.opacity(0.25))
                    .frame(width: isBest ? 14 : 10, height: isBest ? 14 : 10)

                if isBest {
                    Image(systemName: "star.fill")
                        .font(.system(size: 6))
                        .foregroundStyle(.white)
                }
            }
            .padding(.top, 18)

            if !isLast {
                Rectangle()
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 16)
    }
}

struct BestRecordBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "medal.fill")
            Text("Best")
        }
        .font(.caption2.weight(.bold))
        .foregroundStyle(AppTheme.accent)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(AppTheme.accent.opacity(0.12)))
    }
}
