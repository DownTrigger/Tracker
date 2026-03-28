import Foundation

final class HabitCreationViewModel: TrackerCreationViewModel {

    // MARK: - State
    var selectedWeekdays: Set<WeekDay> = [] {
        didSet { onFormValidityChanged?(isFormValid) }
    }

    // MARK: - Override
    override var isFormValid: Bool {
        super.isFormValid && !selectedWeekdays.isEmpty
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
