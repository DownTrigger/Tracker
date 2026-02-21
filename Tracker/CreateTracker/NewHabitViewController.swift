import UIKit

final class NewHabitViewController: UIViewController {

    var onCreateTracker: ((Tracker) -> Void)?

    // MARK: - State
    private var trackerName: String = ""
    private var selectedWeekdays: Set<WeekDay> = []
    private var isShowingLimitMessage = false

    private var isCreateEnabled: Bool {
        !trackerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !selectedWeekdays.isEmpty
    }

    private func updateCreateButtonState() {
        createButton.isEnabled = isCreateEnabled
        createButton.backgroundColor = isCreateEnabled ? AppColors.primaryLabel : AppColors.accentGray
    }

    // MARK: - UI
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.backgroundColor = AppColors.primaryBackground
        table.sectionHeaderHeight = 12
        table.sectionFooterHeight = 12
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
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(AppColors.accentRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = AppColors.accentRed.cgColor
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = AppColors.primaryLabel
        button.setTitleColor(AppColors.primaryBackground, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateCreateButtonState()
    }

    private func setupUI() {
        title = "Новая привычка"
        navigationItem.setHidesBackButton(true, animated: false)
        view.backgroundColor = AppColors.primaryBackground

        view.addSubview(tableView)
        view.addSubview(buttonStack)
        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(createButton)

        additionalSafeAreaInsets = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonStack.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    // MARK: - Actions
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func createTapped() {
        let name = trackerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, !selectedWeekdays.isEmpty else { return }
        let schedule = selectedWeekdays.sorted { $0.rawValue < $1.rawValue }.map { $0.rawValue }
        let tracker = Tracker.create(name: name, schedule: schedule)
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
    
    // MARK: - Cell Configuration
    private func handleNameChange(_ text: String?) {
        trackerName = text ?? ""
        let shouldShowLimit = trackerName.count >= TextFieldCell.maxNameLength
        if shouldShowLimit != isShowingLimitMessage {
            isShowingLimitMessage = shouldShowLimit
            let indexPath = IndexPath(row: 1, section: 0)
            if shouldShowLimit {
                tableView.performBatchUpdates { tableView.insertRows(at: [indexPath], with: .fade) }
            } else {
                tableView.performBatchUpdates { tableView.deleteRows(at: [indexPath], with: .fade) }
            }
        }
        updateCreateButtonState()
    }

    private func nameCell(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.reuseId, for: indexPath) as! TextFieldCell
        cell.configure(placeholder: "Введите название трекера", currentText: trackerName, onText: handleNameChange)
        return cell
    }

    private func categoryCell(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SubtitleCell.reuseId, for: indexPath) as! SubtitleCell
        cell.configure(title: "Категория", subtitle: "Важное")
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    private func scheduleCell(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SubtitleCell.reuseId, for: indexPath) as! SubtitleCell
        cell.configure(title: "Расписание", subtitle: scheduleSubtitle)
        cell.accessoryType = .none
        return cell
    }

    private func nameLimitCell(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.nameLimitCellReuseId, for: indexPath)
        cell.textLabel?.text = TextFieldCell.nameLimitFooterText
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.textLabel?.textColor = AppColors.accentRed
        cell.textLabel?.textAlignment = .center
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        return cell
    }
}

// MARK: - UITableViewDataSource
extension NewHabitViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return trackerName.count >= TextFieldCell.maxNameLength ? 2 : 1
        }
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            return nameCell(in: tableView, at: indexPath)
        case (0, 1):
            return nameLimitCell(in: tableView, at: indexPath)
        case (1, 0):
            return categoryCell(in: tableView, at: indexPath)
        case (1, 1):
            return scheduleCell(in: tableView, at: indexPath)
        default:
            fatalError("Unexpected indexPath: \(indexPath)")
        }
    }
}

// MARK: - UITableViewDelegate
extension NewHabitViewController: UITableViewDelegate {
    private static let cellCornerRadius: CGFloat = 10
    private static let hiddenSeparatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
    private static let defaultSeparatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0, indexPath.row == 1 { return 38 }
        return 75
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        cell.backgroundColor = .clear
        if indexPath.row == 0 {
            configureNameCell(cell, rowCount: tableView.numberOfRows(inSection: 0))
        } else {
            configureWarningCell(cell)
        }
    }

    private func configureNameCell(_ cell: UITableViewCell, rowCount: Int) {
        cell.contentView.backgroundColor = AppColors.secondaryBackground
        cell.contentView.layer.cornerRadius = Self.cellCornerRadius
        cell.contentView.layer.masksToBounds = true
        cell.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        cell.separatorInset = rowCount == 2 ? Self.hiddenSeparatorInset : Self.defaultSeparatorInset
    }

    private func configureWarningCell(_ cell: UITableViewCell) {
        cell.contentView.backgroundColor = .clear
        cell.contentView.layer.cornerRadius = 0
        cell.contentView.layer.maskedCorners = []
        cell.contentView.layer.masksToBounds = false
        cell.separatorInset = Self.hiddenSeparatorInset
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1, indexPath.row == 1 {
            openSchedule()
        }
    }
}
