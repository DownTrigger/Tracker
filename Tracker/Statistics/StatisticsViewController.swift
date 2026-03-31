import UIKit

final class StatisticsViewController: UIViewController {

    // MARK: - ViewModel
    private let viewModel: StatisticsViewModel

    // MARK: - Init
    init(viewModel: StatisticsViewModel = StatisticsViewModel()) {
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

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        bindViewModel()
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
        NSLayoutConstraint.activate([
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.onStateUpdated = { [weak self] in
            guard let self else { return }
            self.emptyStateImageView.isHidden = !self.viewModel.isEmpty
            self.emptyStateLabel.isHidden = !self.viewModel.isEmpty
        }
        viewModel.onStateUpdated?()
    }
}
