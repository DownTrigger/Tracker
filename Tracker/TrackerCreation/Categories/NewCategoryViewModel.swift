import Foundation

final class NewCategoryViewModel {

    // MARK: - State
    var name: String = "" {
        didSet { onFormValidityChanged?(!name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) }
    }

    // MARK: - Bindings
    var onFormValidityChanged: ((Bool) -> Void)?

    // MARK: - Computed
    var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
}
