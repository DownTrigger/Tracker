import Foundation

enum TrackerFilter: Int, CaseIterable {
    case all
    case today
    case completed
    case notCompleted

    var title: String {
        switch self {
        case .all: return "filter_all".localized
        case .today: return "filter_today".localized
        case .completed: return "filter_completed".localized
        case .notCompleted: return "filter_not_completed".localized
        }
    }

    var analyticsItem: String {
        switch self {
        case .all: return "all"
        case .today: return "today"
        case .completed: return "completed"
        case .notCompleted: return "not_completed"
        }
    }
}
