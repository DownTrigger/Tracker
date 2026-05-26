import Foundation

enum TrackerFilter: Int, CaseIterable {
    case all
    case today
    case completed
    case notCompleted

    var title: String {
        switch self {
        case .all: "filter_all".localized
        case .today: "filter_today".localized
        case .completed: "filter_completed".localized
        case .notCompleted: "filter_not_completed".localized
        }
    }

    var analyticsItem: String {
        switch self {
        case .all: "all"
        case .today: "today"
        case .completed: "completed"
        case .notCompleted: "not_completed"
        }
    }
}
