import UIKit

final class HabitCreationViewController: UIViewController {

    // MARK: - Callbacks
    var onCreateTracker: ((Tracker) -> Void)?

    // MARK: - State
    private var trackerName: String = ""
    private var selectedWeekdays: Set<WeekDay> = []
    private var isShowingLimitMessage = false

    private var trimmedName: String {
        trackerName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isCreateEnabled: Bool {
        !trimmedName.isEmpty && !selectedWeekdays.isEmpty
    }

    private var shouldShowNameLimitRow: Bool {
        trackerName.count >= TextFieldCell.maxNameLength
    }

    private func updateCreateButtonState() {
        createButton.isEnabled = isCreateEnabled
        createButton.backgroundColor = isCreateEnabled ? AppColors.primaryLabel : AppColors.accentGray
    }

    // MARK: - UI
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.backgroundColor = AppColors.primaryBackground
        table.sectionHeaderHeight = Constants.tableSectionHeaderHeight
        table.sectionFooterHeight = Constants.tableSectionFooterHeight
        table.delegate = self
        table.dataSource = self
        table.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.reuseId)
        table.register(UITableViewCell.self, forCellReuseIdentifier: TextFieldCell.nameLimitCellReuseId)
        table.register(SubtitleCell.self, forCellReuseIdentifier: SubtitleCell.reuseId)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.cancel, for: .normal)
        button.setTitleColor(AppColors.accentRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.buttonFontSize, weight: .medium)
        button.backgroundColor = .clear
        button.layer.cornerRadius = Constants.buttonCornerRadius
        button.layer.borderWidth = Constants.cancelButtonBorderWidth
        button.layer.borderColor = AppColors.accentRed.cgColor
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.create, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.buttonFontSize, weight: .medium)
        button.backgroundColor = AppColors.primaryLabel
        button.setTitleColor(AppColors.primaryBackground, for: .normal)
        button.layer.cornerRadius = Constants.buttonCornerRadius
        button.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Constants.buttonStackSpacing
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateCreateButtonState()
    }

    // MARK: - Setup
    private func setupUI() {
        title = Strings.screenTitle
        navigationItem.setHidesBackButton(true, animated: false)
        view.backgroundColor = AppColors.primaryBackground
        additionalSafeAreaInsets = Constants.additionalSafeAreaInsets
        setupHierarchy()
        setupConstraints()
    }

    private func setupHierarchy() {
        view.addSubview(tableView)
        view.addSubview(buttonStack)
        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(createButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalPadding),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalPadding),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.bottomPadding),
            buttonStack.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }

    // MARK: - Actions
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func createTapped() {
        guard !trimmedName.isEmpty, !selectedWeekdays.isEmpty else { return }
        let schedule = selectedWeekdays.sorted { $0.rawValue < $1.rawValue }.map { $0.rawValue }
        let tracker = Tracker.create(name: trimmedName, schedule: schedule)
        onCreateTracker?(tracker)
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

    private var scheduleSubtitle: String {
        if selectedWeekdays.isEmpty { return "" }
        let sorted = selectedWeekdays.sorted { $0.rawValue < $1.rawValue }
        if sorted.count == 7 { return "Каждый день" }
        return sorted.map { $0.shortTitle }.joined(separator: ", ")
    }

    // MARK: - State Updates
    private func updateNameLimitRowIfNeeded() {
        guard shouldShowNameLimitRow != isShowingLimitMessage else { return }
        isShowingLimitMessage = shouldShowNameLimitRow
        let indexPath = IndexPath(row: NameRow.nameLimitWarning.rawValue, section: Section.name.rawValue)
        tableView.performBatchUpdates {
            if shouldShowNameLimitRow {
                tableView.insertRows(at: [indexPath], with: .fade)
            } else {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }

    // MARK: - Cell Configuration
    private func handleNameChange(_ text: String?) {
        trackerName = text ?? ""
        updateNameLimitRowIfNeeded()
        updateCreateButtonState()
    }

    private func dequeueNameCell(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.reuseId, for: indexPath) as? TextFieldCell else {
            fatalError("Failed to dequeue \(TextFieldCell.self). Check cell registration.")
        }
        cell.configure(placeholder: Strings.namePlaceholder, currentText: trackerName, onText: handleNameChange)
        return cell
    }

    private func dequeueCategoryCell(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SubtitleCell.reuseId, for: indexPath) as? SubtitleCell else {
            fatalError("Failed to dequeue \(SubtitleCell.self). Check cell registration.")
        }
        cell.configure(title: Strings.categoryTitle, subtitle: Strings.defaultCategoryName)
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    private func dequeueScheduleCell(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SubtitleCell.reuseId, for: indexPath) as? SubtitleCell else {
            fatalError("Failed to dequeue \(SubtitleCell.self). Check cell registration.")
        }
        cell.configure(title: Strings.scheduleTitle, subtitle: scheduleSubtitle)
        cell.accessoryType = .none
        return cell
    }

    private func dequeueNameLimitCell(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.nameLimitCellReuseId, for: indexPath)
        cell.textLabel?.text = TextFieldCell.nameLimitFooterText
        cell.textLabel?.font = .systemFont(ofSize: Constants.warningLabelFontSize)
        cell.textLabel?.textColor = AppColors.accentRed
        cell.textLabel?.textAlignment = .center
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        return cell
    }
}

// MARK: - UITableViewDataSource
extension HabitCreationViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionKind = Section(rawValue: section) else { return 0 }
        switch sectionKind {
        case .name:
            return shouldShowNameLimitRow ? NameRow.allCases.count : 1
        case .category:
            return CategoryRow.allCases.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Unexpected section: \(indexPath.section)")
        }
        switch section {
        case .name:
            guard let row = NameRow(rawValue: indexPath.row) else {
                fatalError("Unexpected row in name section: \(indexPath.row)")
            }
            switch row {
            case .textField:
                return dequeueNameCell(in: tableView, at: indexPath)
            case .nameLimitWarning:
                return dequeueNameLimitCell(in: tableView, at: indexPath)
            }
        case .category:
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
    }
}

// MARK: - UITableViewDelegate
extension HabitCreationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if Section(rawValue: indexPath.section) == .name,
           NameRow(rawValue: indexPath.row) == .nameLimitWarning {
            return Constants.nameLimitRowHeight
        }
        return Constants.standardRowHeight
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard Section(rawValue: indexPath.section) == .name else { return }
        cell.backgroundColor = .clear
        let rowCount = tableView.numberOfRows(inSection: indexPath.section)
        if NameRow(rawValue: indexPath.row) == .textField {
            applyNameCellStyle(cell, rowCount: rowCount)
        } else {
            applyWarningCellStyle(cell)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if Section(rawValue: indexPath.section) == .category,
           CategoryRow(rawValue: indexPath.row) == .schedule {
            openSchedule()
        }
    }

    private func applyNameCellStyle(_ cell: UITableViewCell, rowCount: Int) {
        cell.contentView.backgroundColor = AppColors.secondaryBackground
        cell.contentView.layer.cornerRadius = Constants.cellCornerRadius
        cell.contentView.layer.masksToBounds = true
        cell.contentView.layer.maskedCorners = [
            .layerMinXMinYCorner, .layerMaxXMinYCorner,
            .layerMinXMaxYCorner, .layerMaxXMaxYCorner
        ]
        cell.separatorInset = rowCount > 1 ? Constants.hiddenSeparatorInset : Constants.defaultSeparatorInset
    }

    private func applyWarningCellStyle(_ cell: UITableViewCell) {
        cell.contentView.backgroundColor = .clear
        cell.contentView.layer.cornerRadius = 0
        cell.contentView.layer.maskedCorners = []
        cell.contentView.layer.masksToBounds = false
        cell.separatorInset = Constants.hiddenSeparatorInset
    }
}

// MARK: - Section & Rows
private extension HabitCreationViewController {
    enum Section: Int, CaseIterable {
        case name = 0
        case category = 1
    }

    enum NameRow: Int, CaseIterable {
        case textField = 0
        case nameLimitWarning = 1
    }

    enum CategoryRow: Int, CaseIterable {
        case category = 0
        case schedule = 1
    }
}

// MARK: - Constants
private extension HabitCreationViewController {
    enum Constants {
        static let tableSectionHeaderHeight: CGFloat = 12
        static let tableSectionFooterHeight: CGFloat = 12
        static let buttonFontSize: CGFloat = 16
        static let buttonCornerRadius: CGFloat = 16
        static let buttonHeight: CGFloat = 60
        static let buttonStackSpacing: CGFloat = 8
        static let cancelButtonBorderWidth: CGFloat = 1
        static let horizontalPadding: CGFloat = 20
        static let bottomPadding: CGFloat = 16
        static let additionalSafeAreaInsets = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)
        static let standardRowHeight: CGFloat = 75
        static let nameLimitRowHeight: CGFloat = 38
        static let cellCornerRadius: CGFloat = 10
        static let warningLabelFontSize: CGFloat = 17
        static let hiddenSeparatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        static let defaultSeparatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
    }

    enum Strings {
        static let screenTitle = "Новая привычка"
        static let cancel = "Отменить"
        static let create = "Создать"
        static let namePlaceholder = "Введите название трекера"
        static let categoryTitle = "Категория"
        static let defaultCategoryName = "Важное"
        static let scheduleTitle = "Расписание"
    }
}
