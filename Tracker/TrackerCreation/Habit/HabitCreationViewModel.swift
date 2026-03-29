import Foundation

final class HabitCreationViewModel: TrackerCreationViewModel {

    // MARK: - Init
    override init(categoryStore: TrackerCategoryStore) {
        super.init(categoryStore: categoryStore)
    }

    // MARK: - State
    var selectedWeekdays: Set<WeekDay> = [] {
        didSet { onFormValidityChanged?(isFormValid) }
    }

    // MARK: - Override
    override var isFormValid: Bool {
        super.isFormValid && !selectedWeekdays.isEmpty
    }

    // MARK: - Presentation
    var scheduleSubtitle: String {
        if selectedWeekdays.isEmpty { return "" }
        let sorted = selectedWeekdays.sorted { $0.rawValue < $1.rawValue }
        if sorted.count == 7 { return "Каждый день" }
        return sorted.map { $0.shortTitle }.joined(separator: ", ")
    }

    // MARK: - Factory
    func buildTracker() -> Tracker {
        let schedule = selectedWeekdays
            .sorted { $0.rawValue < $1.rawValue }
            .map(\.rawValue)
        return Tracker.create(
            name: trackerName.trimmingCharacters(in: .whitespacesAndNewlines),
            schedule: schedule,
            emoji: selectedEmoji,
            colorIndex: selectedColorIndex
        )
    }
}
