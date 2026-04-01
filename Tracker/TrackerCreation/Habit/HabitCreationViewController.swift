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

    init(tracker: Tracker, completedDays: Int, categoryName: String, categoryStore: TrackerCategoryStore) {
        let vm = HabitCreationViewModel(tracker: tracker, completedDays: completedDays, categoryStore: categoryStore)
        vm.selectedCategoryTitle = categoryName
        self.habitViewModel = vm
        super.init(viewModel: vm)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override var screenTitle: String {
        habitViewModel.isEditing ? Self.Strings.editScreenTitle : Self.Strings.screenTitle
    }

    override var analyticsScreenName: String { "HabitCreation" }

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
            assertionFailure("Unexpected row in category section: \(indexPath.row)")
            return UITableViewCell()
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
            assertionFailure("Failed to dequeue \(SubtitleCell.self). Check cell registration.")
            return UITableViewCell()
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
        static let screenTitle = "title_new_habit".localized
        static let editScreenTitle = "title_edit_habit".localized
        static let scheduleTitle = "title_schedule".localized
    }
}
