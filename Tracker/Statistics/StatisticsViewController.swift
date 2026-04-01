import UIKit

final class StatisticsViewController: UIViewController {

    // MARK: - ViewModel
    private let viewModel: StatisticsViewModel

    // MARK: - Init
    init(viewModel: StatisticsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - UI
    private let emptyStateImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(resource: .statEmptyState)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "empty_state_statistics".localized
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = AppColors.primaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let bestPeriodCard = StatisticCardView()
    private let idealDaysCard = StatisticCardView()
    private let completedCard = StatisticCardView()
    private let averageCard = StatisticCardView()

    private lazy var cardsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [bestPeriodCard, idealDaysCard, completedCard, averageCard])
        stack.axis = .vertical
        stack.spacing = Constants.cardSpacing
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refresh()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.shared.reportOpen(screen: Strings.analyticsScreen)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.shared.reportClose(screen: Strings.analyticsScreen)
    }

    // MARK: - Setup
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = "title_statistics".localized
    }

    private func setupUI() {
        view.backgroundColor = AppColors.primaryBackground
        view.addSubview(emptyStateImageView)
        view.addSubview(emptyStateLabel)
        view.addSubview(cardsStack)

        NSLayoutConstraint.activate([
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),

            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            cardsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalPadding),
            cardsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalPadding),
            cardsStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            bestPeriodCard.heightAnchor.constraint(equalToConstant: Constants.cardHeight),
        ])
    }

    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.onStateUpdated = { [weak self] in
            guard let self else { return }
            self.updateUI()
        }
        updateUI()
    }

    private func updateUI() {
        let isEmpty = viewModel.isEmpty
        emptyStateImageView.isHidden = !isEmpty
        emptyStateLabel.isHidden = !isEmpty
        cardsStack.isHidden = isEmpty

        bestPeriodCard.configure(value: viewModel.bestPeriod, title: Strings.bestPeriod)
        idealDaysCard.configure(value: viewModel.idealDays, title: Strings.idealDays)
        completedCard.configure(value: viewModel.completedTrackers, title: Strings.completedTrackers)
        averageCard.configure(value: viewModel.averagePerDay, title: Strings.averagePerDay)
    }
}

// MARK: - Constants
private extension StatisticsViewController {
    enum Constants {
        static let cardHeight: CGFloat = 90
        static let cardSpacing: CGFloat = 12
        static let horizontalPadding: CGFloat = 16
    }

    enum Strings {
        static let analyticsScreen = "Statistics"
        static let bestPeriod = "stat_best_period".localized
        static let idealDays = "stat_ideal_days".localized
        static let completedTrackers = "stat_completed_trackers".localized
        static let averagePerDay = "stat_average_per_day".localized
    }
}
