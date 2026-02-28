import UIKit

final class HabitCreationViewController: TrackerCreationViewController {

    // MARK: - State
    var selectedWeekdays: Set<WeekDay> = []

    override var isCreateEnabled: Bool {
        super.isCreateEnabled && !selectedWeekdays.isEmpty
    }

    // MARK: - Overrides
    override var screenTitle: String { Self.Strings.screenTitle }

    override var categoryRowCount: Int { 2 }

    override func performCreate() {
        let schedule = selectedWeekdays.sorted { $0.rawValue < $1.rawValue }.map { $0.rawValue }
        let tracker = Tracker.create(name: trimmedName, schedule: schedule, emoji: selectedEmoji, colorIndex: selectedColorIndex)
        onCreateTracker?(tracker)
    }

    override func cellForCategoryRow(at indexPath: IndexPath) -> UITableViewCell {
        guard let row = CategoryRow(rawValue: indexPath.row) else {
            fatalError("Unexpected row in category section: \(indexPath.row)")
        }
        switch row {
        case .category:
            return dequeueCategoryCell(in: tableView, at: indexPath)
        case .schedule:
            return dequeueScheduleCell(in: tableView, at: indexPath)
        }
    }

    // MARK: - Private
    private var scheduleSubtitle: String {
        if selectedWeekdays.isEmpty { return "" }
        let sorted = selectedWeekdays.sorted { $0.rawValue < $1.rawValue }
        if sorted.count == 7 { return "Каждый день" }
        return sorted.map { $0.shortTitle }.joined(separator: ", ")
    }

    private func dequeueScheduleCell(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SubtitleCell.reuseId, for: indexPath) as? SubtitleCell else {
            fatalError("Failed to dequeue \(SubtitleCell.self). Check cell registration.")
        }
        cell.configure(title: Self.Strings.scheduleTitle, subtitle: scheduleSubtitle)
        cell.accessoryType = .none
        return cell
    }

    private func openSchedule() {
        let scheduleVC = ScheduleViewController()
        scheduleVC.selectedWeekdays = selectedWeekdays
        scheduleVC.onComplete = { [weak self] weekdays in
            self?.selectedWeekdays = weekdays
            self?.tableView.reloadData()
            self?.updateCreateButtonState()
        }
        navigationController?.pushViewController(scheduleVC, animated: true)
    }
}

// MARK: - UITableViewDelegate (schedule row tap)
extension HabitCreationViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        if Section(rawValue: indexPath.section) == .category,
           CategoryRow(rawValue: indexPath.row) == .schedule {
            openSchedule()
        }
    }
}

// MARK: - Section & Rows
private extension HabitCreationViewController {
    enum CategoryRow: Int, CaseIterable {
        case category = 0
        case schedule = 1
    }
}

// MARK: - Strings
private extension HabitCreationViewController {
    enum Strings {
        static let screenTitle = "Новая привычка"
        static let scheduleTitle = "Расписание"
    }
}
