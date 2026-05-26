import Foundation

enum WeekDay: Int, CaseIterable {

    // MARK: - Cases
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    // MARK: - Static
    static let displayOrder: [WeekDay] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    static let fullWeekSchedule: [Int] = allCases.map(\.rawValue)

    // MARK: - Computed
    var shortTitle: String {
        Calendar.current.shortWeekdaySymbols[rawValue - 1].capitalized
    }
    
    var fullTitle: String {
        Calendar.current.weekdaySymbols[rawValue - 1].capitalized
    }
}
