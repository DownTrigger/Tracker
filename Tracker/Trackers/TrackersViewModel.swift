import Foundation

final class TrackersViewModel {

    // MARK: - Bindings
    var onDataUpdated: (() -> Void)?

    // MARK: - Output
    private(set) var displayedCategories: [TrackerCategory] = []

    // MARK: - Private State
    private var allCategories: [TrackerCategory] = []
    private var completedRecords: [TrackerRecord] = []
    private(set) var currentDate: Date = Date()
    private var searchText: String = ""
    private var completedIdsForDate: Set<UUID> = []

    // MARK: - Dependencies
    private let categoryStore: TrackerCategoryStore
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore

    // MARK: - Init
    init(categoryStore: TrackerCategoryStore, trackerStore: TrackerStore, recordStore: TrackerRecordStore) {
        self.categoryStore = categoryStore
        self.trackerStore = trackerStore
        self.recordStore = recordStore
        loadData()
        setupObservers()
    }

    // MARK: - Input
    func setDate(_ date: Date) {
        currentDate = date
        rebuild()
        onDataUpdated?()
    }

    func setSearchText(_ text: String) {
        searchText = text
        rebuild()
        onDataUpdated?()
    }

    func toggleCompletion(trackerId: UUID) {
        if completedIdsForDate.contains(trackerId) {
            recordStore.deleteRecord(trackerId: trackerId, date: currentDate)
        } else {
            recordStore.addRecord(TrackerRecord(trackerId: trackerId, date: currentDate))
        }
    }

    func deleteTracker(id: UUID) {
        trackerStore.deleteTracker(id: id)
        allCategories = categoryStore.categories
        rebuild()
        onDataUpdated?()
    }

    func addTracker(_ tracker: Tracker, categoryName: String) {
        do {
            try trackerStore.addTracker(tracker, toCategoryWithTitle: categoryName)
            allCategories = categoryStore.categories
            rebuild()
            onDataUpdated?()
        } catch {
            assertionFailure("TrackersViewModel: addTracker failed: \(error)")
        }
    }

    // MARK: - Queries
    func isCompletedToday(trackerId: UUID) -> Bool {
        completedIdsForDate.contains(trackerId)
    }

    func completedDaysCount(for trackerId: UUID) -> Int {
        completedRecords.filter { $0.trackerId == trackerId }.count
    }

    func daysCountText(for trackerId: UUID) -> String {
        let n = completedDaysCount(for: trackerId)
        let mod10 = n % 10
        let mod100 = n % 100
        if (11...14).contains(mod100) { return "\(n) дней" }
        switch mod10 {
        case 1: return "\(n) день"
        case 2, 3, 4: return "\(n) дня"
        default: return "\(n) дней"
        }
    }

    func canComplete(for date: Date) -> Bool {
        !isFutureDate(date)
    }

    // MARK: - Private
    private func loadData() {
        allCategories = categoryStore.categories
        completedRecords = recordStore.records
        rebuild()
    }

    private func setupObservers() {
        categoryStore.onChange = { [weak self] in
            guard let self else { return }
            self.allCategories = self.categoryStore.categories
            self.rebuild()
            self.onDataUpdated?()
        }
        recordStore.onChange = { [weak self] in
            guard let self else { return }
            self.completedRecords = self.recordStore.records
            self.rebuildCompletedIds()
            self.onDataUpdated?()
        }
    }

    private func rebuild() {
        rebuildDisplayedCategories()
        rebuildCompletedIds()
    }

    private func rebuildDisplayedCategories() {
        let weekday = Calendar.current.component(.weekday, from: currentDate)
        var result = allCategories.map { category in
            TrackerCategory(
                title: category.title,
                trackers: category.trackers.filter { $0.schedule.contains(weekday) }
            )
        }.filter { !$0.trackers.isEmpty }
        if !searchText.isEmpty {
            result = result.map { category in
                TrackerCategory(
                    title: category.title,
                    trackers: category.trackers.filter {
                        $0.name.localizedCaseInsensitiveContains(searchText)
                    }
                )
            }.filter { !$0.trackers.isEmpty }
        }
        displayedCategories = result
    }

    private func rebuildCompletedIds() {
        let calendar = Calendar.current
        completedIdsForDate = Set(
            completedRecords
                .filter { calendar.isDate($0.date, inSameDayAs: currentDate) }
                .map(\.trackerId)
        )
    }

    private func isFutureDate(_ date: Date) -> Bool {
        Calendar.current.compare(date, to: Date(), toGranularity: .day) == .orderedDescending
    }
}
