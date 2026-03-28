import UIKit

final class HabitCreationViewController: TrackerCreationViewController {

    // MARK: - State
    var selectedWeekdays: Set<WeekDay> = []

    private var habitViewModel: HabitCreationViewModel {
        viewModel as! HabitCreationViewModel
    }

    override var isCreateEnabled: Bool {
        super.isCreateEnabled && !selectedWeekdays.isEmpty
    }

    override func viewDidLoad() {
        viewModel = HabitCreationViewModel()
        super.viewDidLoad()
    }

    override var screenTitle: String { Self.Strings.screenTitle }

    override var categoryRowCount: Int { 2 }

    // MARK: - Actions
    override func performCreate() {
        let tracker = habitViewModel.buildTracker()
        onCreateTracker?(tracker, selectedCategoryTitle ?? Strings.defaultCategoryName)
        navigationController?.dismiss(animated: true)
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
        let scheduleViewModel = ScheduleViewModel(selected: selectedWeekdays)
        let scheduleVC = ScheduleViewController(viewModel: scheduleViewModel)
        scheduleVC.onComplete = { [weak self] weekdays in
            self?.selectedWeekdays = weekdays
            self?.habitViewModel.selectedWeekdays = weekdays
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
        static let defaultCategoryName = "Важное"
    }
}
