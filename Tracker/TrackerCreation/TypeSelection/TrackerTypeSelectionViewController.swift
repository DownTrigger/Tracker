import UIKit

final class TrackerTypeSelectionViewController: UIViewController {

    // MARK: - Callbacks
    var onCreateTracker: ((Tracker, String) -> Void)?

    // MARK: - Dependencies
    private let categoryStore: TrackerCategoryStore
    private let viewModel: TrackerTypeSelectionViewModel

    // MARK: - Init
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
        self.viewModel = TrackerTypeSelectionViewModel()
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - UI
    private lazy var habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.habitTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.buttonFontSize, weight: .medium)
        button.setTitleColor(AppColors.primaryBackground, for: .normal)
        button.backgroundColor = AppColors.primaryLabel
        button.layer.cornerRadius = Constants.buttonCornerRadius
        button.addTarget(self, action: #selector(habitTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var irregularEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Strings.irregularEventTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: Constants.buttonFontSize, weight: .medium)
        button.setTitleColor(AppColors.primaryBackground, for: .normal)
        button.backgroundColor = AppColors.primaryLabel
        button.layer.cornerRadius = Constants.buttonCornerRadius
        button.addTarget(self, action: #selector(irregularEventTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Constants.stackSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    // MARK: - Setup
    private func setupUI() {
        title = Strings.screenTitle
        navigationItem.setHidesBackButton(true, animated: false)
        view.backgroundColor = AppColors.primaryBackground
        setupViewHierarchy()
        setupConstraints()
    }

    private func setupViewHierarchy() {
        view.addSubview(stackView)
        stackView.addArrangedSubview(habitButton)
        stackView.addArrangedSubview(irregularEventButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalPadding),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalPadding),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            habitButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            irregularEventButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }

    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.onHabitSelected = { [weak self] in
            guard let self else { return }
            let vc = HabitCreationViewController(categoryStore: self.categoryStore)
            vc.onCreateTracker = { [weak self] tracker, categoryName in
                self?.onCreateTracker?(tracker, categoryName)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        viewModel.onIrregularSelected = { [weak self] in
            guard let self else { return }
            let vc = IrregularEventCreationViewController(categoryStore: self.categoryStore)
            vc.onCreateTracker = { [weak self] tracker, categoryName in
                self?.onCreateTracker?(tracker, categoryName)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: - Actions
    @objc private func habitTapped() {
        viewModel.habitChosen()
    }

    @objc private func irregularEventTapped() {
        viewModel.irregularChosen()
    }
}

// MARK: - Constants
private extension TrackerTypeSelectionViewController {
    enum Constants {
        // MARK: - Buttons
        static let buttonFontSize: CGFloat = 16
        static let buttonCornerRadius: CGFloat = 16
        static let buttonHeight: CGFloat = 60

        // MARK: - Layout
        static let stackSpacing: CGFloat = 16
        static let horizontalPadding: CGFloat = 20
    }

    enum Strings {
        static let screenTitle = "Создание трекера"
        static let habitTitle = "Привычка"
        static let irregularEventTitle = "Нерегулярное событие"
    }
}
