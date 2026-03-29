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
        store.onChange = { [weak self] in
            self?.reloadCategories()
        }
        reloadCategories()
    }

    // MARK: - Data
    func reloadCategories() {
        categories = store.categories
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

    func deleteCategory(at index: Int) {
        guard index < categories.count else { return }
        store.deleteCategory(withTitle: categories[index].title)
    }
}
