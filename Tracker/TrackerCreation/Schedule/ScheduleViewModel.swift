import Foundation

final class ScheduleViewModel {

    // MARK: - State
    private(set) var selectedWeekdays: Set<WeekDay>

    // MARK: - Init
    init(selected: Set<WeekDay> = []) {
        self.selectedWeekdays = selected
    }

    // MARK: - Actions
    func toggle(_ weekday: WeekDay) {
        if selectedWeekdays.contains(weekday) {
            selectedWeekdays.remove(weekday)
        } else {
            selectedWeekdays.insert(weekday)
        }
    }
}
