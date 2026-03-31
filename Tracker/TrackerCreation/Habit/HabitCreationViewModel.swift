import Foundation

final class HabitCreationViewModel: TrackerCreationViewModel {

    // MARK: - Private
    private var editingTrackerId: UUID?
    private var editingIsPinned: Bool = false

    // MARK: - Override
    override var completedDays: Int { _completedDays }
    private var _completedDays: Int = 0

    // MARK: - Init
    override init(categoryStore: TrackerCategoryStore) {
        super.init(categoryStore: categoryStore)
    }

    init(tracker: Tracker, completedDays: Int, categoryStore: TrackerCategoryStore) {
        super.init(categoryStore: categoryStore)
        editingTrackerId = tracker.id
        editingIsPinned = tracker.isPinned
        trackerName = tracker.name
        selectedEmoji = tracker.emoji
        selectedColorIndex = tracker.color
        selectedWeekdays = Set(tracker.schedule.compactMap { WeekDay(rawValue: $0) })
        _completedDays = completedDays
        isEditing = true
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
        if sorted.count == 7 { return "schedule_every_day".localized }
        return sorted.map { $0.shortTitle }.joined(separator: ", ")
    }

    // MARK: - Factory
    func buildTracker() -> Tracker {
        let schedule = selectedWeekdays
            .sorted { $0.rawValue < $1.rawValue }
            .map(\.rawValue)
        let name = trackerName.trimmingCharacters(in: .whitespacesAndNewlines)
        if let id = editingTrackerId {
            return Tracker(id: id, name: name, color: selectedColorIndex, emoji: selectedEmoji, schedule: schedule, isPinned: editingIsPinned)
        }
        return Tracker.create(
            name: name,
            schedule: schedule,
            emoji: selectedEmoji,
            colorIndex: selectedColorIndex
        )
    }
}
