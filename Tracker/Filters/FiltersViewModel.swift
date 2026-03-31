import Foundation

final class FiltersViewModel {

    // MARK: - State
    private(set) var activeFilter: TrackerFilter

    // MARK: - Bindings
    var onFilterSelected: ((TrackerFilter) -> Void)?

    // MARK: - Init
    init(activeFilter: TrackerFilter) {
        self.activeFilter = activeFilter
    }

    // MARK: - Data
    let filters: [TrackerFilter] = TrackerFilter.allCases

    // MARK: - Actions
    func selectFilter(_ filter: TrackerFilter) {
        activeFilter = filter
        onFilterSelected?(filter)
    }
}
