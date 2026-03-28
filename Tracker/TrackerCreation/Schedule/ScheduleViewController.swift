import UIKit

final class ScheduleViewController: UIViewController {

    // MARK: - State
    private let viewModel: ScheduleViewModel
    var onComplete: ((Set<WeekDay>) -> Void)?

    // MARK: - Init
    init(viewModel: ScheduleViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.delegate = self
        table.dataSource = self
        table.register(ScheduleDayCell.self, forCellReuseIdentifier: ScheduleDayCell.reuseId)
        table.backgroundColor = AppColors.primaryBackground
        table.translatesAutoresizingMaskIntoConstraints = false
        table.isScrollEnabled = false
        table.rowHeight = Constants.rowHeight
        return table
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.done, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.buttonFontSize, weight: .medium)
        button.setTitleColor(AppColors.primaryBackground, for: .normal)
        button.backgroundColor = AppColors.primaryLabel
        button.layer.cornerRadius = Constants.buttonCornerRadius
        button.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Setup
    private func setupUI() {
        title = Strings.screenTitle
        navigationItem.setHidesBackButton(true, animated: false)
        view.backgroundColor = AppColors.primaryBackground
        additionalSafeAreaInsets = Constants.additionalSafeAreaInsets
        setupViewHierarchy()
        setupConstraints()
    }

    private func setupViewHierarchy() {
        view.addSubview(tableView)
        view.addSubview(doneButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalPadding),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalPadding),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.bottomPadding),
            doneButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }

    // MARK: - Actions
    @objc private func doneTapped() {
        onComplete?(viewModel.selectedWeekdays)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        WeekDay.displayOrder.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleDayCell.reuseId, for: indexPath) as? ScheduleDayCell else {
            fatalError("Failed to dequeue \(ScheduleDayCell.self). Check cell registration.")
        }
        let day = WeekDay.displayOrder[indexPath.row]
        cell.configure(
            title: day.fullTitle,
            isOn: viewModel.selectedWeekdays.contains(day),
            onSwitchChanged: { [weak self] _ in
                self?.viewModel.toggle(day)
            }
        )
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
    // TODO: No methods needed yet.
}

// MARK: - Constants
private extension ScheduleViewController {
    enum Constants {
        // MARK: - Table
        static let rowHeight: CGFloat = 75

        // MARK: - Buttons
        static let buttonFontSize: CGFloat = 16
        static let buttonCornerRadius: CGFloat = 16
        static let buttonHeight: CGFloat = 60
        static let horizontalPadding: CGFloat = 20
        static let bottomPadding: CGFloat = 16

        // MARK: - View
        static let additionalSafeAreaInsets = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)
    }

    enum Strings {
        static let screenTitle = "Расписание"
        static let done = "Готово"
    }
}
