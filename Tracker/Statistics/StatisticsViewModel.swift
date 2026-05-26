import Foundation

final class StatisticsViewModel {

    // MARK: - Bindings
    var onStateUpdated: (() -> Void)?

    // MARK: - Output
    private(set) var isEmpty = true
    private(set) var bestPeriod: Int = 0
    private(set) var idealDays: Int = 0
    private(set) var completedTrackers: Int = 0
    private(set) var averagePerDay: Int = 0

    // MARK: - Dependencies
    private let recordStore: TrackerRecordStore
    private let categoryStore: TrackerCategoryStore

    // MARK: - Init
    init(recordStore: TrackerRecordStore, categoryStore: TrackerCategoryStore) {
        self.recordStore = recordStore
        self.categoryStore = categoryStore
    }

    func refresh() {
        computeStats()
    }

    // MARK: - Private
    private func computeStats() {
        let records = recordStore.records
        let allTrackers = categoryStore.categories.flatMap { $0.trackers }

        completedTrackers = records.count
        averagePerDay = computeAveragePerDay(records: records)
        bestPeriod = computeBestPeriod(records: records, trackers: allTrackers)
        idealDays = computeIdealDays(records: records, trackers: allTrackers)
        isEmpty = completedTrackers == 0
        onStateUpdated?()
    }

    private func computeAveragePerDay(records: [TrackerRecord]) -> Int {
        guard !records.isEmpty else { return 0 }
        let calendar = Calendar.current
        let uniqueDays = Set(records.map { calendar.startOfDay(for: $0.date) })
        return records.count / uniqueDays.count
    }

    private func computeBestPeriod(records: [TrackerRecord], trackers: [Tracker]) -> Int {
        let calendar = Calendar.current
        var best = 0
        for tracker in trackers {
            let dates = records
                .filter { $0.trackerId == tracker.id }
                .map { calendar.startOfDay(for: $0.date) }
                .sorted()
            best = max(best, maxStreak(in: dates, calendar: calendar))
        }
        return best
    }

    private func maxStreak(in sortedDates: [Date], calendar: Calendar) -> Int {
        guard !sortedDates.isEmpty else { return 0 }
        var maxCount = 1
        var current = 1
        for i in 1..<sortedDates.count {
            let diff = calendar.dateComponents([.day], from: sortedDates[i - 1], to: sortedDates[i]).day ?? 0
            if diff == 1 {
                current += 1
                maxCount = max(maxCount, current)
            } else if diff > 1 {
                current = 1
            }
        }
        return maxCount
    }

    private func computeIdealDays(records: [TrackerRecord], trackers: [Tracker]) -> Int {
        let calendar = Calendar.current
        let uniqueDays = Set(records.map { calendar.startOfDay(for: $0.date) })
        var count = 0
        for day in uniqueDays {
            let weekday = calendar.component(.weekday, from: day)
            let scheduled = trackers.filter { $0.schedule.contains(weekday) }
            guard !scheduled.isEmpty else { continue }
            let completed = Set(records.filter { calendar.isDate($0.date, inSameDayAs: day) }.map { $0.trackerId })
            if scheduled.allSatisfy({ completed.contains($0.id) }) { count += 1 }
        }
        return count
    }
}
