import Foundation

class TrackerCreationViewModel {

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
    }
}
