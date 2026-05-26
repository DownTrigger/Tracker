import Foundation

final class CategoriesViewModel {

    // MARK: - Bindings
    var onCategoriesUpdated: (([TrackerCategory]) -> Void)?
    var onCategorySelected: ((TrackerCategory) -> Void)?

    // MARK: - State
    private(set) var categories: [TrackerCategory] = []
    private(set) var selectedCategory: TrackerCategory?

    // MARK: - Dependencies
    private let store: TrackerCategoryStore

    // MARK: - Init
    init(store: TrackerCategoryStore, preselected: TrackerCategory? = nil) {
        self.store = store
        self.selectedCategory = preselected
        let previous = store.onChange
        store.onChange = { [weak self] in
            self?.reloadCategories()
            previous?()
        }
        reloadCategories()
    }

    // MARK: - Data
    func reloadCategories() {
        categories = store.categories.filter { $0.title != Constants.pinnedCategoryTitle }
        onCategoriesUpdated?(categories)
    }

    // MARK: - User Actions
    func selectCategory(at index: Int) {
        guard index < categories.count else { return }
        selectedCategory = categories[index]
        onCategorySelected?(categories[index])
    }

    func addCategory(name: String) {
        store.addCategory(name: name)
    }

    func renameCategory(at index: Int, newName: String) {
        guard index < categories.count else { return }
        store.renameCategory(oldTitle: categories[index].title, newTitle: newName)
    }

    func deleteCategory(at index: Int) {
        guard index < categories.count else { return }
        store.deleteCategory(withTitle: categories[index].title)
    }
}

// MARK: - Constants
private extension CategoriesViewModel {
    enum Constants {
        static let pinnedCategoryTitle = "category_pinned".localized
    }
}
