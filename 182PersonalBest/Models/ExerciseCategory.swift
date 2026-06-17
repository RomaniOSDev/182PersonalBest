import Foundation
import SwiftUI

enum ExerciseCategory: String, Codable, CaseIterable, Identifiable {
    case strength
    case cardio
    case flexibility

    var id: String { rawValue }

    var title: String {
        switch self {
        case .strength: return "Strength"
        case .cardio: return "Cardio"
        case .flexibility: return "Flexibility"
        }
    }

    var iconName: String {
        switch self {
        case .strength: return "dumbbell.fill"
        case .cardio: return "figure.run"
        case .flexibility: return "figure.yoga"
        }
    }

    var themeColor: Color {
        AppTheme.accent
    }
}
