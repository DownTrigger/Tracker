import Foundation

class TrackerCreationViewModel {

    // MARK: - Dependencies
    let categoryStore: TrackerCategoryStore

    // MARK: - Init
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
    }

    // MARK: - Editing
    var isEditing: Bool = false

    var createButtonTitle: String {
        isEditing ? "button_save".localized : "button_create".localized
    }

    var completedDays: Int { 0 }

    // MARK: - State
    var trackerName: String = "" {
        didSet { onFormValidityChanged?(isFormValid) }
    }
    var selectedEmoji: String = "" {
        didSet { onFormValidityChanged?(isFormValid) }
    }
    var selectedColorIndex: Int = -1 {
        didSet { onFormValidityChanged?(isFormValid) }
    }
    var selectedCategoryTitle: String? {
        didSet { onFormValidityChanged?(isFormValid) }
    }

    // MARK: - Bindings
    var onFormValidityChanged: ((Bool) -> Void)?

    // MARK: - Computed
    var isFormValid: Bool {
        !trackerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !selectedEmoji.isEmpty
            && selectedColorIndex >= 0
            && selectedCategoryTitle != nil
    }

    // MARK: - Factory
    func buildTracker(schedule: [Int]) -> Tracker {
        Tracker.create(
            name: trackerName.trimmingCharacters(in: .whitespacesAndNewlines),
            schedule: schedule,
            emoji: selectedEmoji,
            colorIndex: selectedColorIndex
        )
    }
}
