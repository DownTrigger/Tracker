import UIKit

final class StatisticsViewController: UIViewController {

    // MARK: - ViewModel
    private let viewModel = StatisticsViewModel()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Setup
    private func setupUI() {
        title = "Статистика"
        view.backgroundColor = AppColors.primaryBackground
    }
}