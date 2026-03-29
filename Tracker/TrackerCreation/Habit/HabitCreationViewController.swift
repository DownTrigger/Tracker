import UIKit

final class HabitCreationViewController: TrackerCreationViewController {

    // MARK: - State
    private let habitViewModel: HabitCreationViewModel

    // MARK: - Init
    init(categoryStore: TrackerCategoryStore) {
        let vm = HabitCreationViewModel(categoryStore: categoryStore)
        self.habitViewModel = vm
        super.init(viewModel: vm)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var screenTitle: String { Self.Strings.screenTitle }

    override var categoryRowCount: Int { 2 }

    // MARK: - Actions
    override func performCreate() {
        guard let categoryTitle = viewModel.selectedCategoryTitle else { return }
        let tracker = habitViewModel.buildTracker()
        onCreateTracker?(tracker, categoryTitle)
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
    private var scheduleSubtitle: String { habitViewModel.scheduleSubtitle }

    private func dequeueScheduleCell(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SubtitleCell.reuseId, for: indexPath) as? SubtitleCell else {
            fatalError("Failed to dequeue \(SubtitleCell.self). Check cell registration.")
        }
        cell.configure(title: Self.Strings.scheduleTitle, subtitle: scheduleSubtitle)
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    private func openSchedule() {
        let scheduleViewModel = ScheduleViewModel(selected: habitViewModel.selectedWeekdays)
        let scheduleVC = ScheduleViewController(viewModel: scheduleViewModel)
        scheduleVC.onComplete = { [weak self] weekdays in
            self?.habitViewModel.selectedWeekdays = weekdays
            self?.tableView.reloadData()
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
